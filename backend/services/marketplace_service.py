# backend/services/marketplace_service.py
from datetime import datetime, timezone
from database import get_db, send_push_notification
from models.order_model import OrderModel


class MarketplaceService:

    # ── Products ──────────────────────────────────────────────────────────────
    @staticmethod
    def get_products(category: str = None, search: str = None) -> list[dict]:
        db    = get_db()
        query = db.collection("products").where("isAvailable", "==", True)
        if category:
            query = query.where("category", "==", category)

        docs     = query.stream()
        products = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            if search:
                q = search.lower()
                if not any(q in str(data.get(f, "")).lower()
                           for f in ["name", "description", "sellerName"]):
                    continue
            products.append(data)

        products.sort(key=lambda x: x.get("createdAt", ""), reverse=True)
        return products

    @staticmethod
    def get_product(product_id: str) -> dict | None:
        doc = get_db().collection("products").document(product_id).get()
        if not doc.exists:
            return None
        data = doc.to_dict()
        data["id"] = doc.id
        return data

    @staticmethod
    def create_product(seller_id: str, seller_name: str, payload: dict) -> dict:
        now = datetime.now(timezone.utc).isoformat()
        db  = get_db()
        ref = db.collection("products").document()
        data = {
            "name":              payload["name"],
            "description":       payload.get("description", ""),
            "pricePerUnit":      float(payload.get("pricePerUnit", 0)),
            "unit":              payload.get("unit", "kg"),
            "category":          payload.get("category", "Vegetables"),
            "imageUrl":          payload.get("imageUrl", ""),
            "availableQuantity": float(payload.get("availableQuantity", 0)),
            "location":          payload.get("location", ""),
            "sellerId":          seller_id,
            "sellerName":        seller_name,
            "isAvailable":       True,
            "createdAt":         now,
            "updatedAt":         now,
        }
        ref.set(data)
        data["id"] = ref.id
        return data

    @staticmethod
    def update_product(product_id: str, seller_id: str, payload: dict) -> dict | None:
        db  = get_db()
        ref = db.collection("products").document(product_id)
        doc = ref.get()
        if not doc.exists or doc.to_dict().get("sellerId") != seller_id:
            return None
        allowed = {"name", "description", "pricePerUnit", "unit",
                   "category", "imageUrl", "isAvailable"}
        updates = {k: v for k, v in payload.items() if k in allowed}
        updates["updatedAt"] = datetime.now(timezone.utc).isoformat()
        ref.update(updates)
        data = ref.get().to_dict()
        data["id"] = product_id
        return data

    @staticmethod
    def delete_product(product_id: str, seller_id: str) -> bool:
        db  = get_db()
        ref = db.collection("products").document(product_id)
        doc = ref.get()
        if not doc.exists or doc.to_dict().get("sellerId") != seller_id:
            return False
        ref.delete()
        return True

    # ── Orders ────────────────────────────────────────────────────────────────
    @staticmethod
    def place_order(buyer_id: str, buyer_name: str, payload: dict) -> dict:
        now      = datetime.now(timezone.utc).isoformat()
        db       = get_db()
        product  = db.collection("products").document(payload["productId"]).get()

        if not product.exists:
            raise ValueError("Product not found")

        pd = product.to_dict()

        if not pd.get("isAvailable", False):
            raise ValueError("Product is no longer available")
        qty      = float(payload.get("quantity", 1))
        ppu      = float(pd.get("pricePerUnit", 0))
        ref      = db.collection("orders").document()

        data = {
            "productId":    payload["productId"],
            "productName":  pd.get("name", ""),
            "buyerId":      buyer_id,
            "buyerName":    buyer_name,
            "sellerId":     pd.get("sellerId", ""),
            "sellerName":   pd.get("sellerName", ""),
            "quantity":     qty,
            "unit":         pd.get("unit", "kg"),
            "pricePerUnit": ppu,
            "totalPrice":   round(qty * ppu, 2),
            "status":       "pending",
            "notes":        payload.get("notes"),
            "location":     payload.get("location", ""),
            "createdAt":    now,
            "updatedAt":    now,
        }
        ref.set(data)

        # Notify seller via FCM if they have a token
        seller_doc = db.collection("users").document(pd.get("sellerId", "")).get()
        if seller_doc.exists:
            fcm = seller_doc.to_dict().get("fcmToken")
            if fcm:
                try:
                    send_push_notification(
                        fcm,
                        title="New Order Received",
                        body=f"{buyer_name} ordered {qty}{pd.get('unit','kg')} of {pd.get('name','')}",
                        data={"type": "order", "orderId": ref.id},
                    )
                except Exception:
                    pass  # Don't fail the order if notification fails

        data["id"] = ref.id
        return OrderModel.from_firestore(ref.id, data).to_dict()

    @staticmethod
    def get_my_orders(buyer_id: str) -> list[dict]:
        db   = get_db()
        docs = (
            db.collection("orders")
              .where("buyerId", "==", buyer_id)
              .order_by("createdAt", direction="DESCENDING")
              .stream()
        )
        return [OrderModel.from_firestore(d.id, d.to_dict()).to_dict() for d in docs]

    @staticmethod
    def get_incoming_orders(seller_id: str) -> list[dict]:
        db   = get_db()
        docs = (
            db.collection("orders")
              .where("sellerId", "==", seller_id)
              .order_by("createdAt", direction="DESCENDING")
              .stream()
        )
        return [OrderModel.from_firestore(d.id, d.to_dict()).to_dict() for d in docs]

    @staticmethod
    def update_order_status(order_id: str, seller_id: str, status: str) -> dict | None:
        valid = {"accepted", "rejected", "delivered"}
        if status not in valid:
            raise ValueError(f"Invalid status. Must be one of {valid}")

        db  = get_db()
        ref = db.collection("orders").document(order_id)
        doc = ref.get()
        if not doc.exists or doc.to_dict().get("sellerId") != seller_id:
            return None

        now = datetime.now(timezone.utc).isoformat()
        ref.update({"status": status, "updatedAt": now})

        updated = ref.get().to_dict()
        # Notify buyer
        buyer_doc = db.collection("users").document(updated.get("buyerId", "")).get()
        if buyer_doc.exists:
            fcm = buyer_doc.to_dict().get("fcmToken")
            if fcm:
                try:
                    send_push_notification(
                        fcm,
                        title=f"Order {status.capitalize()}",
                        body=f"Your order for {updated.get('productName','')} was {status}.",
                        data={"type": "order", "orderId": order_id},
                    )
                except Exception:
                    pass

        return OrderModel.from_firestore(order_id, updated).to_dict()
