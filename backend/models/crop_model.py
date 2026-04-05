# backend/models/crop_model.py
from dataclasses import dataclass
from typing import Optional
from utils.helpers import ts_to_iso

@dataclass
class CropModel:
    id:           str
    name:         str
    type:         str
    quantity:     float
    unit:         str
    location:     str
    planted_date: str
    status:       str
    owner_id:     str
    created_at:   str
    updated_at:   str
    harvest_date: Optional[str] = None
    notes:        Optional[str] = None

    def to_dict(self) -> dict:
        return {
            "id":          self.id,
            "name":        self.name,
            "type":        self.type,
            "quantity":    self.quantity,
            "unit":        self.unit,
            "location":    self.location,
            "plantedDate": self.planted_date,
            "harvestDate": self.harvest_date,
            "status":      self.status,
            "notes":       self.notes,
            "ownerId":     self.owner_id,
            "createdAt":   self.created_at,
            "updatedAt":   self.updated_at,
        }

    @classmethod
    def from_firestore(cls, doc_id: str, data: dict) -> "CropModel":
        return cls(
            id=           doc_id,
            name=         data.get("name", ""),
            type=         data.get("type", "other"),
            quantity=     float(data.get("quantity", 0)),
            unit=         data.get("unit", "kg"),
            location=     data.get("location", ""),
            planted_date= ts_to_iso(data.get("plantedDate")),
            harvest_date= ts_to_iso(data.get("harvestDate")),
            status=       data.get("status", "planted"),
            notes=        data.get("notes"),
            owner_id=     data.get("ownerId", ""),
            created_at=   ts_to_iso(data.get("createdAt")),
            updated_at=   ts_to_iso(data.get("updatedAt")),
        )
