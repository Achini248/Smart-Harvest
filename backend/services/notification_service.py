# backend/services/notification_service.py
from datetime import datetime, timezone
from database import get_db, send_push_notification, send_push_to_topic
from models.notification_model import NotificationModel


class NotificationService:

    @staticmethod
    def get_notifications(owner_id: str) -> list[dict]:
        db   = get_db()
        docs = (
            db.collection("notifications")
              .where("ownerId", "==", owner_id)
              .order_by("createdAt", direction="DESCENDING")
              .limit(50)
              .stream()
        )
        return [NotificationModel.from_firestore(d.id, d.to_dict()).to_dict() for d in docs]

    @staticmethod
    def mark_as_read(notif_id: str, owner_id: str) -> dict | None:
        db  = get_db()
        ref = db.collection("notifications").document(notif_id)
        doc = ref.get()
        if not doc.exists or doc.to_dict().get("ownerId") != owner_id:
            return None
        ref.update({"isRead": True})
        return NotificationModel.from_firestore(notif_id, ref.get().to_dict()).to_dict()

    @staticmethod
    def mark_all_read(owner_id: str) -> int:
        db   = get_db()
        docs = (
            db.collection("notifications")
              .where("ownerId", "==", owner_id)
              .where("isRead", "==", False)
              .stream()
        )
        batch = db.batch()
        count = 0
        for doc in docs:
            batch.update(doc.reference, {"isRead": True})
            count += 1
        if count:
            batch.commit()
        return count

    @staticmethod
    def delete_notification(notif_id: str, owner_id: str) -> bool:
        db  = get_db()
        ref = db.collection("notifications").document(notif_id)
        doc = ref.get()
        if not doc.exists or doc.to_dict().get("ownerId") != owner_id:
            return False
        ref.delete()
        return True

    @staticmethod
    def create_and_push(
        owner_id: str,
        title:    str,
        body:     str,
        notif_type: str = "system",
        priority: str = "medium",
        data:     dict = None,
    ) -> dict:
        """
        Create a Firestore notification record AND send an FCM push.
        Called internally by other services (order placed, price alert, etc.)
        """
        now = datetime.now(timezone.utc).isoformat()
        db  = get_db()
        ref = db.collection("notifications").document()

        doc_data = {
            "ownerId":   owner_id,
            "title":     title,
            "body":      body,
            "type":      notif_type,
            "priority":  priority,
            "isRead":    False,
            "createdAt": now,
        }
        ref.set(doc_data)

        # Push via FCM if user has a token
        user_doc = db.collection("users").document(owner_id).get()
        if user_doc.exists:
            fcm_token = user_doc.to_dict().get("fcmToken")
            if fcm_token:
                try:
                    send_push_notification(fcm_token, title, body, data or {})
                except Exception:
                    pass

        return NotificationModel.from_firestore(ref.id, doc_data).to_dict()

    @staticmethod
    def broadcast_price_alert(crop_name: str, change_pct: float) -> None:
        """Broadcast a price change alert to all subscribed users."""
        direction = "increased" if change_pct > 0 else "decreased"
        title = "Price Alert"
        body  = f"{crop_name} prices {direction} by {abs(change_pct):.1f}%"
        try:
            send_push_to_topic(
                topic="price_alerts",
                title=title,
                body=body,
                data={"type": "price_update", "crop": crop_name},
            )
        except Exception:
            pass
