# backend/config.py
# Smart Harvest — Centralised Configuration

import os
import re
from dotenv import load_dotenv

# Load .env from the backend directory (works whether you run from
# the project root or from inside backend/)
_here = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(_here, ".env"))


class Config:
    # ── Flask ─────────────────────────────────────────────────────────────────
    SECRET_KEY     = os.environ.get("SECRET_KEY", "smartharvest-dev-secret")
    DEBUG          = os.environ.get("FLASK_DEBUG", "true").lower() == "true"
    JSON_SORT_KEYS = False

    # ── Firebase ──────────────────────────────────────────────────────────────
    # Path to your serviceAccountKey.json — NEVER commit this file to git.
    # Resolved relative to the backend/ directory so it works regardless of
    # where you launch the server from.
    _default_key = os.path.join(_here, "serviceAccountKey.json")
    FIREBASE_CREDENTIALS = os.environ.get("FIREBASE_CREDENTIALS", _default_key)
    FIREBASE_PROJECT_ID  = os.environ.get("FIREBASE_PROJECT_ID", "smart-harvest-f27d4")

    # ── Weather API (OpenWeatherMap — free tier) ───────────────────────────────
    # Get your key at: https://openweathermap.org/api
    OPENWEATHER_API_KEY  = os.environ.get("OPENWEATHER_API_KEY", "")
    OPENWEATHER_BASE_URL = "https://api.openweathermap.org/data/2.5"

    # ── SMTP / Email (for OTP delivery) ───────────────────────────────────────
    # Recommended: Gmail with an App Password (not your main account password).
    # 1. Enable 2-Step Verification on your Google account.
    # 2. Go to: Google Account → Security → App passwords → Generate.
    # 3. Set SMTP_USER=you@gmail.com and SMTP_PASSWORD=<16-char app password>.
    #
    # Any other SMTP provider (SendGrid, Mailgun, Mailtrap, etc.) works too —
    # just change the host/port values accordingly.
    SMTP_HOST     = os.environ.get("SMTP_HOST", "smtp.gmail.com")
    SMTP_PORT     = int(os.environ.get("SMTP_PORT", "587"))
    SMTP_USER     = os.environ.get("SMTP_USER", "")
    SMTP_PASSWORD = os.environ.get("SMTP_PASSWORD", "")
    SMTP_FROM     = os.environ.get("SMTP_FROM", "")   # defaults to SMTP_USER if blank

    # ── ML Model ─────────────────────────────────────────────────────────────
    ML_MODEL_DIR     = os.path.join(_here, "price_service", "models")
    WFP_DATA_PATH    = os.path.join(_here, "price_service", "wfp_food_prices_lka.csv")
    FORECAST_DAYS    = 7
    MIN_HISTORY_DAYS = 7

    # ── CORS ──────────────────────────────────────────────────────────────────
    # In DEBUG mode we allow every localhost/127.0.0.1 port so that Flutter web
    # (which picks a random port like :52733) is never CORS-blocked during dev.
    # In production only the explicit origins below are permitted.
    _PRODUCTION_ORIGINS = [
        "https://smartharvest.lk",
        "https://www.smartharvest.lk",
        "https://smart-harvest-f27d4.web.app",
        "https://smart-harvest-f27d4.firebaseapp.com",
    ]

    # Regex patterns accepted by Flask-CORS for any localhost port
    _DEV_ORIGINS = [
        re.compile(r"^http://localhost(:\d+)?$"),
        re.compile(r"^http://127\.0\.0\.1(:\d+)?$"),
        re.compile(r"^http://10\.0\.2\.2(:\d+)?$"),   # Android emulator loopback
    ]

    @classmethod
    def get_cors_origins(cls):
        """Return the right CORS origin list depending on DEBUG flag."""
        if cls.DEBUG:
            return cls._DEV_ORIGINS + cls._PRODUCTION_ORIGINS
        return cls._PRODUCTION_ORIGINS

    # Keep a simple list alias for backward-compat references
    @property
    def CORS_ORIGINS(self):
        return self.get_cors_origins()
