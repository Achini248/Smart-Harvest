from flask import Blueprint, request, jsonify
from services.auth_service import AuthService
from utils.validators import require_fields
from utils.logger import logger

auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")

@auth_bp.post("/register")
def register():
    data = request.get_json(silent=True) or {}
    missing = require_fields(data, ["name", "email", "password", "role"])
    if missing:
        return jsonify({"success": False, "message": f"Missing fields: {missing}"}), 400

    result, error = AuthService.register_user(
        name=data["name"],
        email=data["email"],
        password=data["password"],
        role=data.get("role", "farmer"),
        phone=data.get("phone"),
    )
    if error:
        logger.info(f"Registration failed for {data.get('email')}: {error}")
        return jsonify({"success": False, "message": error}), 400

    return jsonify({"success": True, **result}), 201

@auth_bp.post("/login")
def login():
    data = request.get_json(silent=True) or {}
    missing = require_fields(data, ["email", "password"])
    if missing:
        return jsonify({"success": False, "message": f"Missing fields: {missing}"}), 400

    result, error = AuthService.login_user(
        email=data["email"], password=data["password"]
    )
    if error:
        logger.info(f"Login failed for {data.get('email')}: {error}")
        return jsonify({"success": False, "message": error}), 401

    return jsonify({"success": True, **result}), 200
