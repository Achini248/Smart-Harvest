# backend/services/weather_service.py
# Calls OpenWeatherMap API. Falls back to mock data if no API key is set.

import requests
from flask import current_app


SRI_LANKA_CITIES = {
    "colombo":        {"lat": 6.9271,  "lon": 79.8612},
    "kandy":          {"lat": 7.2906,  "lon": 80.6337},
    "galle":          {"lat": 6.0535,  "lon": 80.2210},
    "jaffna":         {"lat": 9.6615,  "lon": 80.0255},
    "nuwara eliya":   {"lat": 6.9497,  "lon": 80.7891},
    "anuradhapura":   {"lat": 8.3114,  "lon": 80.4037},
    "kurunegala":     {"lat": 7.4818,  "lon": 80.3609},
    "dambulla":       {"lat": 7.8742,  "lon": 80.6511},
    "matara":         {"lat": 5.9549,  "lon": 80.5550},
    "ratnapura":      {"lat": 6.6828,  "lon": 80.3992},
}

CONDITION_ICONS = {
    "Clear":        "sunny",
    "Clouds":       "cloudy",
    "Rain":         "rainy",
    "Drizzle":      "rainy",
    "Thunderstorm": "stormy",
    "Snow":         "snowy",
    "Mist":         "foggy",
    "Haze":         "foggy",
    "Fog":          "foggy",
}


class WeatherService:

    @staticmethod
    def get_weather(location: str) -> dict:
        api_key = current_app.config.get("OPENWEATHER_API_KEY", "")
        if not api_key:
            return WeatherService._mock_weather(location)

        try:
            loc_lower = location.strip().lower()
            coords    = SRI_LANKA_CITIES.get(loc_lower)

            base_url  = current_app.config["OPENWEATHER_BASE_URL"]

            # Current weather
            if coords:
                url = f"{base_url}/weather?lat={coords['lat']}&lon={coords['lon']}&appid={api_key}&units=metric"
            else:
                url = f"{base_url}/weather?q={location},LK&appid={api_key}&units=metric"

            cur  = requests.get(url, timeout=8).json()
            if cur.get("cod") != 200:
                return WeatherService._mock_weather(location)

            # 5-day forecast (3-hour intervals → pick one per day)
            if coords:
                f_url = f"{base_url}/forecast?lat={coords['lat']}&lon={coords['lon']}&appid={api_key}&units=metric"
            else:
                f_url = f"{base_url}/forecast?q={location},LK&appid={api_key}&units=metric"

            fc_data  = requests.get(f_url, timeout=8).json()
            forecast = WeatherService._parse_forecast(fc_data)

            main    = cur["main"]
            weather = cur["weather"][0]
            wind    = cur.get("wind", {})

            return {
                "location":     cur.get("name", location),
                "temperatureC": round(main["temp"], 1),
                "feelsLikeC":   round(main.get("feels_like", main["temp"]), 1),
                "condition":    weather["main"],
                "description":  weather["description"].title(),
                "icon":         CONDITION_ICONS.get(weather["main"], "cloudy"),
                "humidity":     main["humidity"],
                "windSpeedKmh": round(wind.get("speed", 0) * 3.6, 1),
                "forecast":     forecast,
            }

        except Exception:
            return WeatherService._mock_weather(location)

    @staticmethod
    def _parse_forecast(fc_data: dict) -> list[dict]:
        """Extract one forecast entry per day from 3-hour interval data."""
        seen_days = set()
        result    = []
        days_map  = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        for item in fc_data.get("list", []):
            dt_txt = item.get("dt_txt", "")
            day    = dt_txt[:10]
            if day in seen_days or len(result) >= 5:
                continue
            seen_days.add(day)

            import datetime
            d       = datetime.date.fromisoformat(day)
            main    = item["main"]
            weather = item["weather"][0]

            result.append({
                "day":       days_map[d.weekday()],
                "date":      day,
                "highC":     round(main["temp_max"], 1),
                "lowC":      round(main["temp_min"], 1),
                "condition": weather["main"],
                "icon":      CONDITION_ICONS.get(weather["main"], "cloudy"),
            })

        return result

    @staticmethod
    def _mock_weather(location: str) -> dict:
        """Fallback mock data — same structure as the real response."""
        return {
            "location":     location or "Colombo",
            "temperatureC": 29.0,
            "feelsLikeC":   32.0,
            "condition":    "Partly Cloudy",
            "description":  "Partly Cloudy",
            "icon":         "cloudy",
            "humidity":     75,
            "windSpeedKmh": 14.0,
            "forecast": [
                {"day": "Mon", "date": "", "highC": 31.0, "lowC": 24.0, "condition": "Sunny",        "icon": "sunny"},
                {"day": "Tue", "date": "", "highC": 28.0, "lowC": 22.0, "condition": "Rainy",        "icon": "rainy"},
                {"day": "Wed", "date": "", "highC": 30.0, "lowC": 23.0, "condition": "Partly Cloudy","icon": "cloudy"},
                {"day": "Thu", "date": "", "highC": 32.0, "lowC": 25.0, "condition": "Sunny",        "icon": "sunny"},
                {"day": "Fri", "date": "", "highC": 27.0, "lowC": 21.0, "condition": "Rainy",        "icon": "rainy"},
            ],
        }
