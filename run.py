"""Local development entrypoint for the Flask application."""

import os

from dotenv import load_dotenv

load_dotenv()

from app import app  # noqa: E402


if __name__ == "__main__":
    port = int(os.getenv("PORT", 5000))
    debug_enabled = os.getenv("FLASK_DEBUG", "0") == "1"
    app.run(host="0.0.0.0", port=port, debug=debug_enabled)

