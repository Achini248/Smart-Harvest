# backend/routes/notification_routes.py
from flask import Blueprint, request, g
from utils.helpers import firebase_auth_required, success, error
from services.notification_service import NotificationService

notif_bp = Blueprint("notifications", __name__, url_prefix="/api/notifications")


@notif_bp.route("", methods=["GET"])
@firebase_auth_required
def get_notifications():
    return success(NotificationService.get_notifications(g.uid))


@notif_bp.route("/<notif_id>/read", methods=["PUT"])
@firebase_auth_required
def mark_as_read(notif_id):
    result = NotificationService.mark_as_read(notif_id, g.uid)
    if not result:
        return error("Notification not found", 404)
    return success(result)


@notif_bp.route("/read-all", methods=["PUT"])
@firebase_auth_required
def mark_all_read():
    count = NotificationService.mark_all_read(g.uid)
    return success({"message": f"{count} notifications marked as read"})


@notif_bp.route("/<notif_id>", methods=["DELETE"])
@firebase_auth_required
def delete_notification(notif_id):
    if not NotificationService.delete_notification(notif_id, g.uid):
        return error("Notification not found", 404)
    return success({"message": "Notification deleted"})
