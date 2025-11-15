"""Generate PostgreSQL schema and data migration scripts from the local SQLite DB."""

from __future__ import annotations

import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Dict, List

BASE_DIR = Path(__file__).resolve().parents[1]
SQLITE_PATH = BASE_DIR / "instance" / "store.db"
SCHEMA_PATH = BASE_DIR / "schema_postgres.sql"
DATA_PATH = BASE_DIR / "data_migration.sql"


def quote_identifier(name: str) -> str:
    escaped = name.replace('"', '""')
    return f'"{escaped}"'


def map_sqlite_type(declared_type: str, is_serial: bool = False) -> str:
    if is_serial:
        return "SERIAL"
    if not declared_type:
        return "TEXT"
    t = declared_type.upper()
    if "INT" in t:
        return "INTEGER"
    if "CHAR" in t or "CLOB" in t or "TEXT" in t:
        return declared_type
    if "BLOB" in t:
        return "BYTEA"
    if "REAL" in t or "FLOA" in t or "DOUB" in t:
        return "DOUBLE PRECISION"
    if "DEC" in t or "NUM" in t:
        return declared_type
    if "BOOL" in t:
        return "BOOLEAN"
    if "DATE" in t or "TIME" in t:
        return "TIMESTAMP WITH TIME ZONE"
    return declared_type


def normalize_default(default_value: str | None, pg_type: str) -> str | None:
    if default_value is None:
        if "TIMESTAMP" in pg_type:
            return "NOW()"
        return None

    raw = default_value.strip()
    if raw.upper() in {"NULL", "NONE"}:
        return None
    if raw.upper() in {"CURRENT_TIMESTAMP", "NOW()"}:
        return "NOW()"
    if raw in {"0", "1"} and "BOOLEAN" in pg_type:
        return "TRUE" if raw == "1" else "FALSE"
    if raw.startswith(("'", '"')) and raw.endswith(("'", '"')):
        inner = raw[1:-1].replace("''", "'")
        sanitized = inner.replace("'", "''")
        return f"'{sanitized}'"
    return raw


def format_value(value, column_type: str) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if column_type and "BOOL" in column_type.upper():
        text_value = str(value)
        return "TRUE" if text_value in {"1", "True", "true", "t", "T"} else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, datetime):
        return f"'{value.strftime('%Y-%m-%d %H:%M:%S')}'"
    text_value = str(value)
    sanitized = text_value.replace("'", "''")
    return f"'{sanitized}'"


def fetch_tables(conn: sqlite3.Connection) -> List[str]:
    cursor = conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
    )
    return [row[0] for row in cursor.fetchall()]


def build_schema(conn: sqlite3.Connection) -> Dict[str, List[str]]:
    serial_pk_map: Dict[str, str] = {}
    schema_lines: List[str] = [
        "-- Auto-generated PostgreSQL schema\n",
        "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";\n",
    ]

    for table in fetch_tables(conn):
        columns_info = conn.execute(f"PRAGMA table_info('{table}')").fetchall()
        pk_columns = [col[1] for col in columns_info if col[5]]
        single_integer_pk = len(pk_columns) == 1
        if single_integer_pk:
            pk_declared = next(col for col in columns_info if col[1] == pk_columns[0])[2] or ""
            single_integer_pk = "INT" in pk_declared.upper()
        column_defs = []
        table_constraints = []

        for col in columns_info:
            name = col[1]
            declared_type = col[2] or ""
            notnull = bool(col[3])
            default_value = col[4]
            is_pk = bool(col[5])
            use_serial = single_integer_pk and is_pk

            if use_serial:
                serial_pk_map[table] = name

            pg_type = map_sqlite_type(declared_type, use_serial)
            parts = [quote_identifier(name), pg_type]

            if not use_serial and notnull:
                parts.append("NOT NULL")

            default_clause = normalize_default(default_value, pg_type)
            if default_clause:
                parts.append(f"DEFAULT {default_clause}")

            column_defs.append("    " + " ".join(parts))

        if not single_integer_pk and pk_columns:
            pk_cols = ", ".join(quote_identifier(col) for col in pk_columns)
            table_constraints.append(f"    PRIMARY KEY ({pk_cols})")

        fk_rows = conn.execute(f"PRAGMA foreign_key_list('{table}')").fetchall()
        for fk in fk_rows:
            local_cols = quote_identifier(fk[3])
            remote_cols = quote_identifier(fk[4])
            clause = (
                f"    FOREIGN KEY ({local_cols}) REFERENCES "
                f"{quote_identifier(fk[2])} ({remote_cols})"
            )
            if fk[6] and fk[6] != "NO ACTION":
                clause += f" ON UPDATE {fk[6]}"
            if fk[5] and fk[5] != "NO ACTION":
                clause += f" ON DELETE {fk[5]}"
            table_constraints.append(clause)

        index_rows = conn.execute(f"PRAGMA index_list('{table}')").fetchall()
        for idx in index_rows:
            unique = idx[2]
            origin = idx[3] if len(idx) > 3 else 'c'
            if not unique or origin != 'u':
                continue
            idx_info = conn.execute(f"PRAGMA index_info('{idx[1]}')").fetchall()
            idx_cols = ", ".join(quote_identifier(info[2]) for info in idx_info)
            table_constraints.append(f"    UNIQUE ({idx_cols})")

        table_body = column_defs + table_constraints
        schema_lines.append(f'CREATE TABLE {quote_identifier(table)} (\n' +
                            ",\n".join(table_body) +
                            "\n);\n")

    SCHEMA_PATH.write_text("\n".join(schema_lines), encoding="utf-8")
    return serial_pk_map


def build_data_dump(conn: sqlite3.Connection, serial_map: Dict[str, str]) -> None:
    conn.row_factory = sqlite3.Row
    lines: List[str] = [
        "-- Auto-generated data migration",
        "BEGIN;",
    ]

    for table in fetch_tables(conn):
        columns_info = conn.execute(f"PRAGMA table_info('{table}')").fetchall()
        type_map = {col[1]: col[2] or "" for col in columns_info}
        rows = conn.execute(f'SELECT * FROM "{table}"').fetchall()
        if not rows:
            continue

        columns = rows[0].keys()
        quoted_columns = ", ".join(quote_identifier(col) for col in columns)

        for row in rows:
            values = ", ".join(format_value(row[col], type_map.get(col, "")) for col in columns)
            lines.append(
                f'INSERT INTO {quote_identifier(table)} ({quoted_columns}) VALUES ({values});'
            )

        if table in serial_map:
            pk = serial_map[table]
            sequence_literal = quote_identifier(table)
            lines.append(
                f"SELECT setval("
                f"pg_get_serial_sequence('{sequence_literal}', '{pk}'), "
                f"COALESCE(MAX({quote_identifier(pk)}), 0) + 1, true"
                f") FROM {quote_identifier(table)};"
            )

    lines.append("COMMIT;")
    DATA_PATH.write_text("\n".join(lines), encoding="utf-8")


def main():
    if not SQLITE_PATH.exists():
        raise FileNotFoundError(f"SQLite database not found at {SQLITE_PATH}")

    conn = sqlite3.connect(SQLITE_PATH)
    try:
        serial_map = build_schema(conn)
        build_data_dump(conn, serial_map)
        print(f"Schema written to {SCHEMA_PATH}")
        print(f"Data migration written to {DATA_PATH}")
    finally:
        conn.close()


if __name__ == "__main__":
    main()

