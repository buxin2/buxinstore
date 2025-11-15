"""Vercel-compatible WSGI entrypoint."""

import os
from pathlib import Path

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent

# Load environment variables for local testing; Vercel injects them automatically
dotenv_path = BASE_DIR / ".env"
if dotenv_path.exists():
    load_dotenv(dotenv_path)
else:
    load_dotenv()

from app import app as application  # noqa: E402


if __name__ == "__main__":
    port = int(os.getenv("PORT", 5000))
    application.run(host="0.0.0.0", port=port, debug=False)

