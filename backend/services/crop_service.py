# backend/services/crop_service.py
from datetime import datetime, timezone
from database import get_db
from models.crop_model import CropModel


class CropService:

    @staticmethod
    def get_crops(owner_id: str) -> list[dict]:
        db   = get_db()
        docs = (
            db.collection("crops")
              .where("ownerId", "==", owner_id)
              .order_by("createdAt", direction="DESCENDING")
              .stream()
        )
        return [CropModel.from_firestore(d.id, d.to_dict()).to_dict() for d in docs]

    @staticmethod
    def get_crop(crop_id: str, owner_id: str) -> dict | None:
        db  = get_db()
        doc = db.collection("crops").document(crop_id).get()
        if not doc.exists:
            return None
        data = doc.to_dict()
        if data.get("ownerId") != owner_id:
            return None   # not this user's crop
        return CropModel.from_firestore(doc.id, data).to_dict()

    @staticmethod
    def add_crop(owner_id: str, payload: dict) -> dict:
        now = datetime.now(timezone.utc).isoformat()
        db  = get_db()
        ref = db.collection("crops").document()

        data = {
            "name":        payload["name"],
            "type":        payload.get("type", "other"),
            "quantity":    float(payload.get("quantity", 0)),
            "unit":        payload.get("unit", "kg"),
            "location":    payload.get("location", ""),
            "plantedDate": payload.get("plantedDate", now),
            "harvestDate": payload.get("harvestDate"),
            "status":      payload.get("status", "planted"),
            "notes":       payload.get("notes"),
            "ownerId":     owner_id,
            "createdAt":   now,
            "updatedAt":   now,
        }
        ref.set(data)
        return CropModel.from_firestore(ref.id, data).to_dict()

    @staticmethod
    def update_crop(crop_id: str, owner_id: str, payload: dict) -> dict | None:
        db  = get_db()
        ref = db.collection("crops").document(crop_id)
        doc = ref.get()

        if not doc.exists or doc.to_dict().get("ownerId") != owner_id:
            return None

        allowed = {"name", "type", "quantity", "unit", "location",
                   "plantedDate", "harvestDate", "status", "notes"}
        updates = {k: v for k, v in payload.items() if k in allowed}
        updates["updatedAt"] = datetime.now(timezone.utc).isoformat()
        ref.update(updates)

        doc = ref.get()
        return CropModel.from_firestore(crop_id, doc.to_dict()).to_dict()

    @staticmethod
    def delete_crop(crop_id: str, owner_id: str) -> bool:
        db  = get_db()
        ref = db.collection("crops").document(crop_id)
        doc = ref.get()
        if not doc.exists or doc.to_dict().get("ownerId") != owner_id:
            return False
        ref.delete()
        return True

    @staticmethod
    def get_all_crops_summary() -> dict:
        """Aggregate crop stats for the government dashboard."""
        db   = get_db()
        docs = db.collection("crops").stream()

        total = 0
        dist: dict[str, int] = {}
        status_count: dict[str, int] = {}

        for doc in docs:
            d    = doc.to_dict()
            total += 1
            crop_type = d.get("type", "other")
            dist[crop_type] = dist.get(crop_type, 0) + 1
            st = d.get("status", "planted")
            status_count[st] = status_count.get(st, 0) + 1

        return {
            "totalCrops":        total,
            "cropDistribution":  dist,
            "statusDistribution": status_count,
        }
