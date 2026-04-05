# backend/routes/auth_routes.py
# Smart Harvest — Authentication Routes
# MODIFIED: added OTP send/verify endpoints for registration flow.

from flask import Blueprint, request, g, current_app
from utils.helpers import firebase_auth_required, success, error
from services.auth_service import AuthService
from services.otp_service import OtpService

auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")


# ── Profile ───────────────────────────────────────────────────────────────────

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
    GET /api/auth/me — alias for GET /api/auth/profile.
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


# ── OTP — Registration Verification ──────────────────────────────────────────

@auth_bp.route("/otp/send", methods=["POST"])
def send_otp():
    """
    POST /api/auth/otp/send
    Body: { "email": "user@example.com" }

    Generates a 6-digit OTP, stores it in Firestore with a 10-minute TTL,
    and sends it to the provided email address.
    No auth required — the user is not registered yet.
    """
    body  = request.get_json(silent=True) or {}
    email = (body.get("email") or "").strip().lower()

    if not email or "@" not in email or "." not in email.split("@")[-1]:
        return error("A valid email address is required.", 400)

    try:
        result = OtpService.send_otp(email)
        return success(result)
    except RuntimeError as exc:
        # Surface the real reason to the client (SMTP misconfiguration, etc.)
        return error(str(exc), 503)
    except Exception as exc:
        import traceback
        current_app.logger.error("send_otp unexpected error: %s", traceback.format_exc())
        return error(f"Failed to send OTP: {exc}", 500)


@auth_bp.route("/otp/verify", methods=["POST"])
def verify_otp():
    """
    POST /api/auth/otp/verify
    Body: { "email": "user@example.com", "otp": "123456" }

    Verifies the OTP. On success the stored record is deleted (single-use).
    The Flutter app should then proceed with Firebase createUserWithEmailAndPassword.
    No auth required — the user is not registered yet.
    """
    body  = request.get_json(silent=True) or {}
    email = (body.get("email") or "").strip().lower()
    otp   = (body.get("otp")   or "").strip()

    if not email or not otp:
        return error("email and otp are required.", 400)

    try:
        result = OtpService.verify_otp(email, otp)
        return success(result)
    except ValueError as exc:
        return error(str(exc), 422)
    except Exception as exc:
        return error(f"Verification failed: {exc}", 500)


# ── Spec-compliance stubs ─────────────────────────────────────────────────────

@auth_bp.route("/register", methods=["POST"])
def register_stub():
    return success({
        "message": (
            "Registration is handled by Firebase Auth after OTP verification. "
            "Step 1: POST /api/auth/otp/send  "
            "Step 2: POST /api/auth/otp/verify  "
            "Step 3: Firebase createUserWithEmailAndPassword  "
            "Step 4: POST /api/auth/profile"
        )
    })


@auth_bp.route("/login", methods=["POST"])
def login_stub():
    return success({
        "message": (
            "Login is handled by Firebase Auth. "
            "Send the Firebase ID token as 'Authorization: Bearer <token>' "
            "on all protected endpoints."
        )
    })
