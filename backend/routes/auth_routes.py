<<<<<<< HEAD
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
=======
# backend/routes/auth_routes.py
# MODIFIED: added /me alias, /register and /login stubs for Growise spec
from flask import Blueprint, request, g
from utils.helpers import firebase_auth_required, success, error
from services.auth_service import AuthService

auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")


@auth_bp.route("/profile", methods=["GET"])
@firebase_auth_required
def get_profile():
    profile = AuthService.get_profile(g.uid)
    if not profile:
        return error("Profile not found", 404)
    return success(profile)


@auth_bp.route("/me", methods=["GET"])
@firebase_auth_required
def get_me():
    """
    GET /api/auth/me — Growise spec alias for GET /api/auth/profile.
    Returns the currently authenticated user's profile.
    """
    profile = AuthService.get_profile(g.uid)
    if not profile:
        return error("Profile not found", 404)
    return success(profile)


@auth_bp.route("/profile", methods=["POST"])
@firebase_auth_required
def create_or_sync_profile():
    """Called right after Firebase login to sync/create the Firestore profile."""
    body  = request.get_json(silent=True) or {}
    email = body.get("email") or g.email
    name  = body.get("name")
    return success(AuthService.get_or_create_profile(g.uid, email, name))


@auth_bp.route("/register", methods=["POST"])
def register_stub():
    """
    POST /api/auth/register
    Registration is handled by Firebase Auth in the Flutter app.
    This endpoint acknowledges the call for spec compliance.
    After Firebase registration, Flutter calls POST /api/auth/profile to sync.
    """
    return success({
        "message": "Registration is handled by Firebase Auth. "
                   "Call POST /api/auth/profile after Firebase signup to sync your profile."
    })


@auth_bp.route("/login", methods=["POST"])
def login_stub():
    """
    POST /api/auth/login
    Login is handled by Firebase Auth in the Flutter app.
    This endpoint acknowledges the call for spec compliance.
    After Firebase login, Flutter sends the ID token via Authorization header.
    """
    return success({
        "message": "Login is handled by Firebase Auth. "
                   "Send the Firebase ID token as 'Authorization: Bearer <token>' on all protected endpoints."
    })


@auth_bp.route("/profile", methods=["PUT"])
@firebase_auth_required
def update_profile():
    body = request.get_json(silent=True) or {}
    return success(AuthService.update_profile(g.uid, body))


@auth_bp.route("/fcm-token", methods=["POST"])
@firebase_auth_required
def update_fcm_token():
    body  = request.get_json(silent=True) or {}
    token = body.get("fcmToken", "")
    if not token:
        return error("fcmToken is required", 400)
    AuthService.update_profile(g.uid, {"fcmToken": token})
    return success({"message": "FCM token updated"})


@auth_bp.route("/delete", methods=["DELETE"])
@firebase_auth_required
def delete_account():
    AuthService.delete_account(g.uid)
    return success({"message": "Account deleted"})

>>>>>>> ddbef5e9db3a8e5ea8f1ef25cdf5bcfa36295850
