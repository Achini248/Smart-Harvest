# backend/models/message_model.py
from dataclasses import dataclass
from typing import Optional
from utils.helpers import ts_to_iso

@dataclass
class MessageModel:
    id:              str
    conversation_id: str
    sender_id:       str
    sender_name:     str
    receiver_id:     str
    receiver_name:   str
    content:         str
    is_read:         bool
    created_at:      str

    def to_dict(self) -> dict:
        return {
            "id":             self.id,
            "conversationId": self.conversation_id,
            "senderId":       self.sender_id,
            "senderName":     self.sender_name,
            "receiverId":     self.receiver_id,
            "receiverName":   self.receiver_name,
            "content":        self.content,
            "isRead":         self.is_read,
            "createdAt":      self.created_at,
        }

    @classmethod
    def from_firestore(cls, doc_id: str, data: dict) -> "MessageModel":
        return cls(
            id=              doc_id,
            conversation_id= data.get("conversationId", ""),
            sender_id=       data.get("senderId",   ""),
            sender_name=     data.get("senderName", ""),
            receiver_id=     data.get("receiverId", ""),
            receiver_name=   data.get("receiverName", ""),
            content=         data.get("content",  ""),
            is_read=         data.get("isRead",   False),
            created_at=      ts_to_iso(data.get("createdAt")),
        )
