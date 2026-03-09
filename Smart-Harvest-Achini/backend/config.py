import os
from datetime import timedelta

class Config:
    # Load from environment in production
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-change-me")
    MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/smart_harvest")

    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "jwt-secret-change-me")
    JWT_ALGORITHM = "HS256"
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=12)

    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
    OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

    WEATHER_API_KEY = os.getenv("WEATHER_API_KEY", "")
    WEATHER_API_URL = "https://api.openweathermap.org/data/2.5/weather"

    # Logging
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
