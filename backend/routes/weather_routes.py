# backend/routes/weather_routes.py
from flask import Blueprint, request, g
from utils.helpers import firebase_auth_required, success, error
from services.weather_service import WeatherService

weather_bp = Blueprint("weather", __name__, url_prefix="/api/weather")


@weather_bp.route("", methods=["GET"])
@firebase_auth_required
def get_weather():
    location = request.args.get("location", "Colombo")
    return success(WeatherService.get_weather(location))
