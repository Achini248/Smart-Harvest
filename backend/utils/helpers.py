# backend/utils/helpers.py
# Smart Harvest — Shared Utilities

import functools
from flask import request, jsonify, g
from database import verify_firebase_token
from firebase_admin.auth import InvalidIdTokenError, ExpiredIdTokenError


# ── Response Helpers ──────────────────────────────────────────────────────────
def success(data, status: int = 200):
    return jsonify({"success": True, "data": data}), status


def error(message: str, status: int = 400):
    return jsonify({"success": False, "error": message, "code": status}), status


# ── Firebase Token Auth Decorator ─────────────────────────────────────────────
def firebase_auth_required(f):
    """
    Decorator that verifies the Firebase ID token from the Flutter app.
    Sets g.uid and g.user_role for use in route handlers.

    Flutter must send: Authorization: Bearer <Firebase ID Token>
    """
    @functools.wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return error("Authorization header missing or malformed", 401)

        id_token = auth_header.split(" ", 1)[1]
        try:
            decoded   = verify_firebase_token(id_token)
            g.uid     = decoded["uid"]
            g.email   = decoded.get("email", "")
            # Custom claims set via Firebase Admin: e.g. {"role": "farmer"}
            g.role    = decoded.get("role", "farmer")
        except ExpiredIdTokenError:
            return error("Token expired. Please log in again.", 401)
        except InvalidIdTokenError as e:
            return error(f"Invalid token: {e}", 401)
        except Exception as e:
            return error(f"Authentication failed: {e}", 401)

        return f(*args, **kwargs)
    return decorated


# ── Role Guard ────────────────────────────────────────────────────────────────
def role_required(*allowed_roles: str):
    """Use after @firebase_auth_required to restrict to specific roles."""
    def decorator(f):
        @functools.wraps(f)
        def decorated(*args, **kwargs):
            if getattr(g, "role", None) not in allowed_roles:
                return error(f"Access denied. Required: {allowed_roles}", 403)
            return f(*args, **kwargs)
        return decorated
    return decorator


# ── Pagination ────────────────────────────────────────────────────────────────
def paginate(items: list, page: int = 1, per_page: int = 20) -> dict:
    total       = len(items)
    total_pages = max(1, (total + per_page - 1) // per_page)
    page        = max(1, min(page, total_pages))
    start       = (page - 1) * per_page
    return {
        "items":       items[start: start + per_page],
        "page":        page,
        "per_page":    per_page,
        "total":       total,
        "total_pages": total_pages,
    }


# ── Firestore Timestamp Helper ────────────────────────────────────────────────
def ts_to_iso(value) -> str:
    """Convert a Firestore Timestamp or datetime to ISO string."""
    if value is None:
        return None
    if hasattr(value, "isoformat"):
        return value.isoformat()
    if hasattr(value, "timestamp"):      # Firestore DatetimeWithNanoseconds
        return value.isoformat()
    return str(value)
