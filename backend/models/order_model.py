# backend/models/order_model.py
from dataclasses import dataclass
from typing import Optional
from utils.helpers import ts_to_iso

@dataclass
class OrderModel:
    id:            str
    product_id:    str
    product_name:  str
    buyer_id:      str
    buyer_name:    str
    seller_id:     str
    seller_name:   str
    quantity:      float
    unit:          str
    price_per_unit: float
    total_price:   float
    status:        str        # pending | accepted | rejected | delivered
    location:      str
    created_at:    str
    updated_at:    str
    notes:         Optional[str] = None

    def to_dict(self) -> dict:
        return {
            "id":           self.id,
            "productId":    self.product_id,
            "productName":  self.product_name,
            "buyerId":      self.buyer_id,
            "buyerName":    self.buyer_name,
            "sellerId":     self.seller_id,
            "sellerName":   self.seller_name,
            "quantity":     self.quantity,
            "unit":         self.unit,
            "pricePerUnit": self.price_per_unit,
            "totalPrice":   self.total_price,
            "status":       self.status,
            "notes":        self.notes,
            "location":     self.location,
            "createdAt":    self.created_at,
            "updatedAt":    self.updated_at,
        }

    @classmethod
    def from_firestore(cls, doc_id: str, data: dict) -> "OrderModel":
        return cls(
            id=             doc_id,
            product_id=     data.get("productId",   ""),
            product_name=   data.get("productName", ""),
            buyer_id=       data.get("buyerId",     ""),
            buyer_name=     data.get("buyerName",   ""),
            seller_id=      data.get("sellerId",    ""),
            seller_name=    data.get("sellerName",  ""),
            quantity=       float(data.get("quantity",     0)),
            unit=           data.get("unit", "kg"),
            price_per_unit= float(data.get("pricePerUnit", 0)),
            total_price=    float(data.get("totalPrice",   0)),
            status=         data.get("status", "pending"),
            notes=          data.get("notes"),
            location=       data.get("location", ""),
            created_at=     ts_to_iso(data.get("createdAt")),
            updated_at=     ts_to_iso(data.get("updatedAt")),
        )
