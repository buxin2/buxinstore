import os
from datetime import timedelta
from pathlib import Path
from typing import Optional

from sqlalchemy.pool import QueuePool


BASE_DIR = Path(__file__).resolve().parent.parent
DEFAULT_SQLITE_PATH = BASE_DIR / "instance" / "store.db"


def _normalize_database_url(raw_url: Optional[str]) -> str:
    if not raw_url:
        return f"sqlite:///{DEFAULT_SQLITE_PATH}"
    if raw_url.startswith("postgres://"):
        return raw_url.replace("postgres://", "postgresql://", 1)
    return raw_url


class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-key-change-this-in-production")

    DATABASE_URL = os.environ.get("DATABASE_URL") or os.environ.get("NEON_DATABASE_URL")
    SQLITE_FALLBACK_URI = os.environ.get(
        "SQLITE_FALLBACK_URI", f"sqlite:///{DEFAULT_SQLITE_PATH}"
    )

    SQLALCHEMY_DATABASE_URI = _normalize_database_url(
        DATABASE_URL or os.environ.get("SQLALCHEMY_DATABASE_URI") or SQLITE_FALLBACK_URI
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        "poolclass": QueuePool,
        "pool_size": int(os.environ.get("SQLALCHEMY_POOL_SIZE", 5)),
        "max_overflow": int(os.environ.get("SQLALCHEMY_MAX_OVERFLOW", 10)),
        "pool_timeout": int(os.environ.get("SQLALCHEMY_POOL_TIMEOUT", 30)),
        "pool_recycle": int(os.environ.get("SQLALCHEMY_POOL_RECYCLE", 280)),
    }

    UPLOAD_FOLDER = "static/uploads"
    ALLOWED_EXTENSIONS = {
        "png",
        "jpg",
        "jpeg",
        "gif",
        "webp",
        "mp4",
        "mov",
        "avi",
        "pdf",
        "docx",
    }
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024

    CLOUDINARY_CLOUD_NAME = os.environ.get("CLOUDINARY_CLOUD_NAME")
    CLOUDINARY_API_KEY = os.environ.get("CLOUDINARY_API_KEY")
    CLOUDINARY_API_SECRET = os.environ.get("CLOUDINARY_API_SECRET")
    CLOUDINARY_URL = os.environ.get("CLOUDINARY_URL")

    PERMANENT_SESSION_LIFETIME = timedelta(days=7)


class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_ECHO = True


class ProductionConfig(Config):
    DEBUG = False


class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    WTF_CSRF_ENABLED = False
