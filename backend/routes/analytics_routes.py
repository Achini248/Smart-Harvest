# backend/routes/analytics_routes.py
# MODIFIED: added /summary and /region endpoints for Growise spec
from flask import Blueprint, g
from utils.helpers import firebase_auth_required, role_required, success
from services.analytics_service import AnalyticsService

analytics_bp = Blueprint("analytics", __name__, url_prefix="/api/analytics")


@analytics_bp.route("", methods=["GET"])
@firebase_auth_required
def get_user_analytics():
    """Per-farmer analytics: their own crops, orders, revenue."""
    return success(AnalyticsService.get_user_analytics(g.uid))


@analytics_bp.route("/platform", methods=["GET"])
@firebase_auth_required
@role_required("officer", "admin")
def get_platform_analytics():
    """Platform-wide analytics (government / admin only)."""
    return success(AnalyticsService.get_platform_analytics())


@analytics_bp.route("/summary", methods=["GET"])
@firebase_auth_required
def get_analytics_summary():
    """
    GET /api/analytics/summary
    Returns the current user's analytics summary (crops, orders, revenue).
    Wraps get_user_analytics for Growise spec compatibility.
    """
    data = AnalyticsService.get_user_analytics(g.uid)
    return success({
        "total_crops":       data.get("totalCrops",    0),
        "total_orders":      data.get("totalOrders",   0),
        "total_revenue":     data.get("totalRevenue",  0),
        "crop_distribution": data.get("cropDistribution", {}),
    })


@analytics_bp.route("/region", methods=["GET"])
@firebase_auth_required
@role_required("officer", "admin")
def get_region_analytics():
    """
    GET /api/analytics/region
    Returns region-level production breakdown for the government dashboard.
    Aggregates crop quantity by user location from Firestore.
    """
    return success(AnalyticsService.get_region_analytics())

