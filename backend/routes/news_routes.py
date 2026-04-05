# backend/routes/news_routes.py
# Smart Harvest — News Routes
# Public endpoint: no auth required (guest users can see news on home screen)

from flask import Blueprint, request
from utils.helpers import success
from services.news_service import NewsService

news_bp = Blueprint("news", __name__, url_prefix="/api/news")


@news_bp.route("", methods=["GET"])
def get_news():
    """
    GET /api/news
    Returns agriculture news items.
    No auth required — visible to guest users on the home screen.
    Query params:
      limit  (int, default 6)  — max number of items
    """
    limit = min(int(request.args.get("limit", 6)), 10)
    items = NewsService.get_news(limit)
    return success({"news": items, "count": len(items)})

