# backend/routes/marketplace_routes.py
# FIX: GET /products is now public — anyone (including guests) can browse
#      the marketplace.  All write operations (POST/PUT/DELETE products,
#      all order routes) remain protected by @firebase_auth_required.

from flask import Blueprint, request, g
from utils.helpers import firebase_auth_required, success, error, paginate
from utils.validators import require_fields
from services.marketplace_service import MarketplaceService

market_bp = Blueprint("marketplace", __name__, url_prefix="/api/marketplace")


@market_bp.route("/products", methods=["GET"])
def get_products():
    # FIX: Removed @firebase_auth_required.
    # The marketplace listing is public — all users (and guests) should be
    # able to browse crops listed by farmers. Authentication is still required
    # to place orders or list your own products.
    category = request.args.get("category")
    search   = request.args.get("search")
    page     = int(request.args.get("page",     1))
    per_page = int(request.args.get("per_page", 20))
    products = MarketplaceService.get_products(category, search)
    return success(paginate(products, page, per_page))


@market_bp.route("/products/<product_id>", methods=["GET"])
def get_product(product_id):
    # FIX: Also made individual product lookup public so the detail sheet works
    # for unauthenticated users browsing the marketplace.
    product = MarketplaceService.get_product(product_id)
    if not product:
        return error("Product not found", 404)
    return success(product)


@market_bp.route("/products", methods=["POST"])
@firebase_auth_required
def create_product():
    body    = request.get_json(silent=True) or {}
    missing = require_fields(body, ["name", "pricePerUnit", "unit", "category"])
    if missing:
        return error(f"Missing fields: {missing}", 400)

    from services.auth_service import AuthService
    profile = AuthService.get_profile(g.uid)
    seller_name = (profile or {}).get("name", "Unknown Seller")

    return success(MarketplaceService.create_product(g.uid, seller_name, body), 201)


@market_bp.route("/products/<product_id>", methods=["PUT"])
@firebase_auth_required
def update_product(product_id):
    body    = request.get_json(silent=True) or {}
    updated = MarketplaceService.update_product(product_id, g.uid, body)
    if not updated:
        return error("Product not found or access denied", 404)
    return success(updated)


@market_bp.route("/products/<product_id>", methods=["DELETE"])
@firebase_auth_required
def delete_product(product_id):
    if not MarketplaceService.delete_product(product_id, g.uid):
        return error("Product not found or access denied", 404)
    return success({"message": "Product deleted"})


@market_bp.route("/orders", methods=["POST"])
@firebase_auth_required
def place_order():
    body    = request.get_json(silent=True) or {}
    missing = require_fields(body, ["productId", "quantity"])
    if missing:
        return error(f"Missing fields: {missing}", 400)
    try:
        from services.auth_service import AuthService
        profile    = AuthService.get_profile(g.uid)
        buyer_name = (profile or {}).get("name", "Unknown Buyer")
        order      = MarketplaceService.place_order(g.uid, buyer_name, body)
        return success(order, 201)
    except ValueError as e:
        return error(str(e), 400)


@market_bp.route("/orders/my", methods=["GET"])
@firebase_auth_required
def get_my_orders():
    return success(MarketplaceService.get_my_orders(g.uid))


@market_bp.route("/orders/incoming", methods=["GET"])
@firebase_auth_required
def get_incoming_orders():
    return success(MarketplaceService.get_incoming_orders(g.uid))


@market_bp.route("/orders/<order_id>/status", methods=["PUT"])
@firebase_auth_required
def update_order_status(order_id):
    body   = request.get_json(silent=True) or {}
    status = body.get("status", "")
    try:
        updated = MarketplaceService.update_order_status(order_id, g.uid, status)
        if not updated:
            return error("Order not found or access denied", 404)
        return success(updated)
    except ValueError as e:
        return error(str(e), 400)
