# backend/routes/crop_routes.py
from flask import Blueprint, request, g
from utils.helpers import firebase_auth_required, success, error
from utils.validators import require_fields
from services.crop_service import CropService

crop_bp = Blueprint("crops", __name__, url_prefix="/api/crops")


@crop_bp.route("", methods=["GET"])
@firebase_auth_required
def get_crops():
    return success(CropService.get_crops(g.uid))


@crop_bp.route("/<crop_id>", methods=["GET"])
@firebase_auth_required
def get_crop(crop_id):
    crop = CropService.get_crop(crop_id, g.uid)
    if not crop:
        return error("Crop not found", 404)
    return success(crop)


@crop_bp.route("", methods=["POST"])
@firebase_auth_required
def add_crop():
    body    = request.get_json(silent=True) or {}
    missing = require_fields(body, ["name", "type", "quantity", "unit", "location", "plantedDate"])
    if missing:
        return error(f"Missing fields: {missing}", 400)
    return success(CropService.add_crop(g.uid, body), 201)


@crop_bp.route("/<crop_id>", methods=["PUT"])
@firebase_auth_required
def update_crop(crop_id):
    body    = request.get_json(silent=True) or {}
    updated = CropService.update_crop(crop_id, g.uid, body)
    if not updated:
        return error("Crop not found or access denied", 404)
    return success(updated)


@crop_bp.route("/<crop_id>", methods=["DELETE"])
@firebase_auth_required
def delete_crop(crop_id):
    if not CropService.delete_crop(crop_id, g.uid):
        return error("Crop not found or access denied", 404)
    return success({"message": "Crop deleted"})


# ── Growise spec aliases ──────────────────────────────────────────────────────

@crop_bp.route("/all", methods=["GET"])
@firebase_auth_required
def get_all_crops():
    """GET /api/crops/all — returns current user's crops (spec alias)."""
    return success(CropService.get_crops(g.uid))


@crop_bp.route("/add", methods=["POST"])
@firebase_auth_required
def add_crop_alias():
    """POST /api/crops/add — spec alias for POST /api/crops."""
    body    = request.get_json(silent=True) or {}
    missing = require_fields(body, ["name", "type", "quantity", "unit", "location", "plantedDate"])
    if missing:
        return error(f"Missing fields: {missing}", 400)
    return success(CropService.add_crop(g.uid, body), 201)
