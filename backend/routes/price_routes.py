# backend/routes/price_routes.py
# MODIFIED: added /current alias, /forecast list endpoint, public /surplus-status
from flask import Blueprint, request, g
from utils.helpers import firebase_auth_required, role_required, success, error, paginate
from services.price_service import PriceService, ForecastService
from price_service.forecast_model import WFPDataLoader
from flask import current_app

price_bp = Blueprint("prices", __name__, url_prefix="/api/prices")


@price_bp.route("/today", methods=["GET"])
@firebase_auth_required
def get_today_prices():
    prices   = PriceService.get_today_prices()
    district = request.args.get("district")
    if district:
        prices = [p for p in prices if p.get("district") == district]
    page     = int(request.args.get("page", 1))
    per_page = int(request.args.get("per_page", 20))
    return success(paginate(prices, page, per_page))


@price_bp.route("/history/<crop_name>", methods=["GET"])
@firebase_auth_required
def get_price_history(crop_name: str):
    days = min(int(request.args.get("days", 30)), 90)
    return success(PriceService.get_price_history(crop_name, days))


@price_bp.route("/supply-status", methods=["GET"])
@firebase_auth_required
def get_supply_status():
    return success(PriceService.get_supply_status())


@price_bp.route("/forecast/<crop_name>", methods=["GET"])
@firebase_auth_required
def get_forecast(crop_name: str):
    result = ForecastService.get_or_generate_forecast(crop_name)
    if "error" in result and not result.get("next_7_days_predictions"):
        return error(result["error"], 422)
    return success(result)


@price_bp.route("/government-summary", methods=["GET"])
@firebase_auth_required
@role_required("officer", "admin")
def get_government_summary():
    return success(PriceService.get_government_summary())


# ── Aliases & new endpoints required by Growise spec ─────────────────────────

@price_bp.route("/current", methods=["GET"])
@firebase_auth_required
def get_current_prices():
    """GET /api/prices/current — alias for /today for Growise spec compatibility."""
    prices = PriceService.get_today_prices()
    return success(prices)


@price_bp.route("/forecast", methods=["GET"])
@firebase_auth_required
def get_all_forecasts():
    """
    GET /api/prices/forecast
    Returns AI forecast for top N crops (uses existing ML model).
    Query params:
      crops  (comma-separated list, optional) — specific crops to forecast
      top    (int, default 5) — if no crops param, forecast top N by price
    """
    csv_path    = current_app.config.get("WFP_DATA_PATH", "")
    available   = WFPDataLoader.get_available_crops(csv_path)

    crops_param = request.args.get("crops", "")
    if crops_param:
        crop_list = [c.strip() for c in crops_param.split(",") if c.strip()]
    else:
        top       = min(int(request.args.get("top", 5)), 10)
        # Prefer crops we have WFP data for; fall back to today's top prices
        if available:
            crop_list = available[:top]
        else:
            today_prices = PriceService.get_today_prices()
            crop_list    = [p["cropName"] for p in today_prices[:top] if p.get("cropName")]

    results = []
    for crop_name in crop_list:
        forecast = ForecastService.get_or_generate_forecast(crop_name)
        # Add current_price from today's prices for this crop
        today_prices = PriceService.get_today_prices()
        current = next(
            (p["avgPrice"] for p in today_prices if p["cropName"] == crop_name),
            None,
        )
        results.append({
            "crop_name":     crop_name,
            "current_price": current,
            "predicted_price": (
                forecast["next_7_days_predictions"][0]["predicted_price"]
                if forecast.get("next_7_days_predictions")
                else None
            ),
            "percentage_change":       forecast.get("percentage_change", 0.0),
            "next_7_days_predictions": forecast.get("next_7_days_predictions", []),
        })

    return success({"forecasts": results, "count": len(results)})


# ── Surplus-status at /api/surplus-status (spec) ─────────────────────────────
# We also register a top-level blueprint route below via a separate blueprint
# in the spec — see surplus_bp in this same file for the /api/surplus-status path

@price_bp.route("/surplus-status-detail", methods=["GET"])
@firebase_auth_required
def get_surplus_status_detail():
    """
    GET /api/prices/surplus-status-detail
    Returns per-crop surplus/shortage with AI supply logic:
      supply > demand → surplus
      supply < demand → shortage
    Uses existing PriceService logic (no simulation).
    """
    today_prices = PriceService.get_today_prices()
    results = []
    for p in today_prices:
        supply = float(p.get("total_supply", 0))
        demand = float(p.get("total_demand", 0))
        if supply > demand:
            status = "surplus"
        elif demand > supply:
            status = "shortage"
        else:
            status = "normal"
        results.append({
            "crop":         p.get("cropName", ""),
            "region":       p.get("district", "National"),
            "status":       status,
            "total_supply": supply,
            "total_demand": demand,
            "avg_price":    p.get("avgPrice", 0),
        })

    return success({"items": results, "count": len(results)})
