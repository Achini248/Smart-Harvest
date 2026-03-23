

# backend/config.py
# Smart Harvest — Centralised Configuration

import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    # ── Flask ─────────────────────────────────────────────────────────────────
    SECRET_KEY   = os.environ.get("SECRET_KEY", "smartharvest-dev-secret")
    DEBUG        = os.environ.get("FLASK_DEBUG", "true").lower() == "true"
    JSON_SORT_KEYS = False

    # ── Firebase ──────────────────────────────────────────────────────────────
    # Path to your serviceAccountKey.json (never commit this file)
    FIREBASE_CREDENTIALS = os.environ.get("FIREBASE_CREDENTIALS", "serviceAccountKey.json")
    FIREBASE_PROJECT_ID  = os.environ.get("FIREBASE_PROJECT_ID",  "smart-harvest-f27d4")

    # ── Weather API (OpenWeatherMap — free tier) ───────────────────────────────
    # Get your key at: https://openweathermap.org/api
    OPENWEATHER_API_KEY  = os.environ.get("OPENWEATHER_API_KEY", "")
    OPENWEATHER_BASE_URL = "https://api.openweathermap.org/data/2.5"

    # ── ML Model ─────────────────────────────────────────────────────────────
    ML_MODEL_DIR     = os.path.join(os.path.dirname(__file__), "price_service", "models")
    WFP_DATA_PATH    = os.path.join(os.path.dirname(__file__), "price_service", "wfp_food_prices_lka.csv")
    FORECAST_DAYS    = 7
    MIN_HISTORY_DAYS = 7

    # ── CORS ──────────────────────────────────────────────────────────────────
    CORS_ORIGINS = ["http://localhost:*", "https://smartharvest.lk"]

