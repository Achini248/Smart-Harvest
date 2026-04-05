# backend/models/notification_model.py
from dataclasses import dataclass
from typing import Optional
from utils.helpers import ts_to_iso

@dataclass
class NotificationModel:
    id:         str
    owner_id:   str
    title:      str
    body:       str
    type:       str      # price_update | weather_alert | order | system
    priority:   str      # high | medium | low
    is_read:    bool
    created_at: str
    image_url:  Optional[str] = None
    action_url: Optional[str] = None

    def to_dict(self) -> dict:
        return {
            "id":        self.id,
            "ownerId":   self.owner_id,
            "title":     self.title,
            "body":      self.body,
            "type":      self.type,
            "priority":  self.priority,
            "isRead":    self.is_read,
            "imageUrl":  self.image_url,
            "actionUrl": self.action_url,
            "createdAt": self.created_at,
        }

    @classmethod
    def from_firestore(cls, doc_id: str, data: dict) -> "NotificationModel":
        return cls(
            id=         doc_id,
            owner_id=   data.get("ownerId",  ""),
            title=      data.get("title",    ""),
            body=       data.get("body",     ""),
            type=       data.get("type",     "system"),
            priority=   data.get("priority", "low"),
            is_read=    data.get("isRead",   False),
            created_at= ts_to_iso(data.get("createdAt")),
            image_url=  data.get("imageUrl"),
            action_url= data.get("actionUrl"),
        )
