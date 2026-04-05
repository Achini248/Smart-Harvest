# backend/routes/surplus_routes.py
# Smart Harvest — Surplus/Shortage Route
# FIX: Removed @firebase_auth_required — this data is informational and
#      should be accessible to all users on the home screen.

from flask import Blueprint, request
from utils.helpers import success
from services.price_service import PriceService

surplus_bp = Blueprint("surplus", __name__, url_prefix="/api")


@surplus_bp.route("/surplus-status", methods=["GET"])
def get_surplus_status():
    """
    GET /api/surplus-status
    Returns per-crop surplus/shortage detection using existing Firestore
    supply/demand data. Now public — no login required.
    Optional query: ?crop=Tomato  to filter a single crop
    Optional query: ?region=Colombo  to filter by district
    """
    today_prices = PriceService.get_today_prices()

    crop_filter   = request.args.get("crop", "").strip().lower()
    region_filter = request.args.get("region", "").strip().lower()

    results = []
    for p in today_prices:
        crop_name = p.get("cropName", "")
        region    = p.get("district", "National")

        if crop_filter and crop_name.lower() != crop_filter:
            continue
        if region_filter and region.lower() != region_filter:
            continue

        supply = float(p.get("total_supply", 0))
        demand = float(p.get("total_demand", 0))

        if supply > demand:
            status = "surplus"
        elif demand > supply:
            status = "shortage"
        else:
            status = "normal"

        results.append({
            "crop":         crop_name,
            "region":       region,
            "status":       status,
            "total_supply": supply,
            "total_demand": demand,
            "avg_price":    p.get("avgPrice", 0),
            "market":       p.get("marketName", ""),
        })

    summary = PriceService.get_supply_status()

    return success({
        "items":   results,
        "count":   len(results),
        "summary": summary,
    })
