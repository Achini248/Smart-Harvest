# backend/routes/weather_routes.py
from flask import Blueprint, request
from utils.helpers import success
from services.weather_service import WeatherService

weather_bp = Blueprint("weather", __name__, url_prefix="/api/weather")


@weather_bp.route("", methods=["GET"])
def get_weather():
    # FIX: Removed @firebase_auth_required — weather is public data shown
    # on the home screen for both guests and logged-in users.
    location = request.args.get("location", "Colombo")
    return success(WeatherService.get_weather(location))
