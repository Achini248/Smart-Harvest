# backend/services/chat_service.py
from datetime import datetime, timezone
from database import get_db, send_push_notification
from models.message_model import MessageModel


def _conv_id(uid_a: str, uid_b: str) -> str:
    """Deterministic, order-independent conversation ID."""
    return "_".join(sorted([uid_a, uid_b]))


class ChatService:

    @staticmethod
    def get_conversations(user_id: str) -> list[dict]:
        """Return all conversation summaries for a user."""
        db   = get_db()
        docs = (
            db.collection("conversations")
              .where("participants", "array_contains", user_id)
              .order_by("lastMessageAt", direction="DESCENDING")
              .stream()
        )
        result = []
        for doc in docs:
            data        = doc.to_dict()
            data["id"]  = doc.id
            # Unread count for this user only
            data["unreadCount"] = data.get("unreadCount", {}).get(user_id, 0)
            result.append(data)
        return result

    @staticmethod
    def get_messages(conversation_id: str, limit: int = 50) -> list[dict]:
        db   = get_db()
        docs = (
            db.collection("messages")
              .where("conversationId", "==", conversation_id)
              .order_by("createdAt")
              .limit_to_last(limit)
              .stream()
        )
        return [MessageModel.from_firestore(d.id, d.to_dict()).to_dict() for d in docs]

    @staticmethod
    def send_message(
        sender_id:     str,
        sender_name:   str,
        receiver_id:   str,
        receiver_name: str,
        content:       str,
    ) -> dict:
        now     = datetime.now(timezone.utc).isoformat()
        db      = get_db()
        conv_id = _conv_id(sender_id, receiver_id)

        # Write message document
        ref = db.collection("messages").document()
        msg_data = {
            "conversationId": conv_id,
            "senderId":       sender_id,
            "senderName":     sender_name,
            "receiverId":     receiver_id,
            "receiverName":   receiver_name,
            "content":        content,
            "isRead":         False,
            "createdAt":      now,
        }
        ref.set(msg_data)

        # Update / create conversation summary (upsert)
        db.collection("conversations").document(conv_id).set(
            {
                "participants": [sender_id, receiver_id],
                "participantNames": {
                    sender_id:   sender_name,
                    receiver_id: receiver_name,
                },
                "lastMessage":   content,
                "lastMessageAt": now,
                "lastSenderId":  sender_id,
                "unreadCount":   {receiver_id: 1},  # client increments on receipt
            },
            merge=True,
        )

        # FCM push to receiver
        receiver_doc = db.collection("users").document(receiver_id).get()
        if receiver_doc.exists:
            fcm = receiver_doc.to_dict().get("fcmToken")
            if fcm:
                try:
                    send_push_notification(
                        fcm,
                        title=f"Message from {sender_name}",
                        body=content[:80],
                        data={"type": "chat", "conversationId": conv_id},
                    )
                except Exception:
                    pass

        return MessageModel.from_firestore(ref.id, msg_data).to_dict()

    @staticmethod
    def mark_as_read(conversation_id: str, user_id: str) -> None:
        db = get_db()
        # Reset unread counter for this user in the conversation summary
        db.collection("conversations").document(conversation_id).update(
            {f"unreadCount.{user_id}": 0}
        )
        # Mark all unread messages sent to this user as read
        docs = (
            db.collection("messages")
              .where("conversationId", "==", conversation_id)
              .where("receiverId",     "==", user_id)
              .where("isRead",         "==", False)
              .stream()
        )
        batch = db.batch()
        for doc in docs:
            batch.update(doc.reference, {"isRead": True})
        batch.commit()
