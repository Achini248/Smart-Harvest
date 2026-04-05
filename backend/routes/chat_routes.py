# backend/routes/chat_routes.py
from flask import Blueprint, request, g
from utils.helpers import firebase_auth_required, success, error
from utils.validators import require_fields
from services.chat_service import ChatService

chat_bp = Blueprint("chat", __name__, url_prefix="/api/chat")


@chat_bp.route("/conversations", methods=["GET"])
@firebase_auth_required
def get_conversations():
    return success(ChatService.get_conversations(g.uid))


@chat_bp.route("/conversations/<conv_id>/messages", methods=["GET"])
@firebase_auth_required
def get_messages(conv_id):
    limit = int(request.args.get("limit", 50))
    return success(ChatService.get_messages(conv_id, limit))


@chat_bp.route("/messages", methods=["POST"])
@firebase_auth_required
def send_message():
    body    = request.get_json(silent=True) or {}
    missing = require_fields(body, ["receiverId", "receiverName", "content"])
    if missing:
        return error(f"Missing fields: {missing}", 400)

    from services.auth_service import AuthService
    profile     = AuthService.get_profile(g.uid)
    sender_name = (profile or {}).get("name", "Unknown")

    msg = ChatService.send_message(
        sender_id=     g.uid,
        sender_name=   sender_name,
        receiver_id=   body["receiverId"],
        receiver_name= body["receiverName"],
        content=       body["content"],
    )
    return success(msg, 201)


@chat_bp.route("/conversations/<conv_id>/read", methods=["PUT"])
@firebase_auth_required
def mark_as_read(conv_id):
    ChatService.mark_as_read(conv_id, g.uid)
    return success({"message": "Marked as read"})
