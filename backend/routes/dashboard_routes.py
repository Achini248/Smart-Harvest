# backend/routes/dashboard_routes.py
from flask import Blueprint, g
from utils.helpers import firebase_auth_required, role_required, success
from services.dashboard_service import DashboardService

dashboard_bp = Blueprint("dashboard", __name__, url_prefix="/api/dashboard")


@dashboard_bp.route("", methods=["GET"])
@firebase_auth_required
@role_required("officer", "admin")
def get_dashboard():
    """National stats for the GovernmentDashboardPage."""
    return success(DashboardService.get_stats())
