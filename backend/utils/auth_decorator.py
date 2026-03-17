from functools import wraps
from flask import request, jsonify
from services.auth_service import AuthService

def jwt_required(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
      auth_header = request.headers.get("Authorization", "")
      if not auth_header.startswith("Bearer "):
          return jsonify({"success": False, "message": "Missing or invalid token."}), 401
      token = auth_header.split(" ", 1)[1].strip()
      user_id = AuthService.decode_token(token)
      if not user_id:
          return jsonify({"success": False, "message": "Invalid or expired token."}), 401
      request.user_id = user_id
      return fn(*args, **kwargs)
    return wrapper
