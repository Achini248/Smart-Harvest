# backend/services/analytics_service.py
# MODIFIED: added get_region_analytics
from database import get_db
from models.analytics_model import AnalyticsModel


class AnalyticsService:

    @staticmethod
    def get_user_analytics(owner_id: str) -> dict:
        """Per-farmer analytics: their crops, orders, revenue."""
        db = get_db()

        # Crops
        crop_docs = (
            db.collection("crops")
              .where("ownerId", "==", owner_id)
              .stream()
        )
        total_crops = 0
        crop_dist: dict[str, float] = {}
        for doc in crop_docs:
            d     = doc.to_dict()
            total_crops += 1
            name  = d.get("name", "Other")
            qty   = float(d.get("quantity", 0))
            crop_dist[name] = crop_dist.get(name, 0) + qty

        # Orders (as seller)
        order_docs = (
            db.collection("orders")
              .where("sellerId", "==", owner_id)
              .stream()
        )
        total_orders  = 0
        total_revenue = 0.0
        for doc in order_docs:
            d = doc.to_dict()
            if d.get("status") in ("accepted", "delivered"):
                total_orders  += 1
                total_revenue += float(d.get("totalPrice", 0))

        return AnalyticsModel(
            total_crops=       total_crops,
            total_orders=      total_orders,
            total_revenue=     total_revenue,
            crop_distribution= crop_dist,
        ).to_dict()

    @staticmethod
    def get_platform_analytics() -> dict:
        """Platform-wide analytics for government / admin dashboard."""
        db = get_db()

        # Farmers count
        user_docs = db.collection("users").where("role", "==", "farmer").stream()
        total_farmers = sum(1 for _ in user_docs)

        # All crops
        crop_docs = db.collection("crops").stream()
        total_crops = 0
        crop_dist: dict[str, int] = {}
        for doc in crop_docs:
            d = doc.to_dict()
            total_crops += 1
            t = d.get("type", "other")
            crop_dist[t] = crop_dist.get(t, 0) + 1

        # All orders
        order_docs = db.collection("orders").stream()
        total_orders  = 0
        total_revenue = 0.0
        for doc in order_docs:
            d = doc.to_dict()
            if d.get("status") in ("accepted", "delivered"):
                total_orders  += 1
                total_revenue += float(d.get("totalPrice", 0))

        return {
            "totalFarmers":     total_farmers,
            "totalCrops":       total_crops,
            "totalOrders":      total_orders,
            "totalRevenue":     round(total_revenue, 2),
            "cropDistribution": crop_dist,
        }

    @staticmethod
    def get_region_analytics() -> dict:
        """
        Region-level production breakdown.
        Groups crop quantities by the farmer's stored location field.
        """
        db = get_db()

        # Build uid → location map from users
        uid_to_location: dict[str, str] = {}
        for doc in db.collection("users").stream():
            d = doc.to_dict()
            loc = d.get("location") or d.get("district") or "Unknown"
            uid_to_location[doc.id] = str(loc).strip() or "Unknown"

        # Aggregate crop quantities per region
        region_totals: dict[str, dict] = {}
        for doc in db.collection("crops").stream():
            d        = doc.to_dict()
            owner    = d.get("ownerId", "")
            region   = uid_to_location.get(owner, "Unknown")
            qty      = float(d.get("quantity", 0))
            crop_name = d.get("name", "Other")

            if region not in region_totals:
                region_totals[region] = {"total_quantity": 0.0, "crops": {}, "farmer_count": set()}
            region_totals[region]["total_quantity"]    += qty
            region_totals[region]["farmer_count"].add(owner)
            region_totals[region]["crops"][crop_name] = (
                region_totals[region]["crops"].get(crop_name, 0) + qty
            )

        result = []
        for region, data in sorted(region_totals.items(), key=lambda kv: kv[1]["total_quantity"], reverse=True):
            result.append({
                "region":         region,
                "total_quantity": round(data["total_quantity"], 2),
                "farmer_count":   len(data["farmer_count"]),
                "top_crops":      sorted(data["crops"].items(), key=lambda kv: kv[1], reverse=True)[:5],
            })

        return {"regions": result, "total_regions": len(result)}
