# backend/services/dashboard_service.py
from datetime import datetime, timezone
from database import get_db
from services.analytics_service import AnalyticsService


class DashboardService:

    @staticmethod
    def get_stats() -> dict:
        """
        Aggregate national stats for the GovernmentDashboardPage.
        Reads from a cached 'dashboard_stats/national' document if fresh (<1hr),
        otherwise recomputes and updates the cache.
        """
        db  = get_db()
        ref = db.collection("dashboard_stats").document("national")
        doc = ref.get()

        if doc.exists:
            data    = doc.to_dict()
            updated = data.get("updatedAt", "")
            # Use cached data if less than 1 hour old
            if updated:
                try:
                    age = (datetime.now(timezone.utc) -
                           datetime.fromisoformat(str(updated).replace("Z", "+00:00")))
                    if age.total_seconds() < 3600:
                        data.pop("updatedAt", None)
                        return data
                except Exception:
                    pass

        # Recompute from Firestore collections
        platform = AnalyticsService.get_platform_analytics()

        # Supply analysis from daily_prices (from your price_service data)
        from datetime import date
        today     = date.today().isoformat()
        price_docs = db.collection("daily_prices").where("date", "==", today).stream()
        surplus_regions  = 0
        shortage_regions = 0
        for pdoc in price_docs:
            pd = pdoc.to_dict()
            if float(pd.get("total_supply", 0)) > float(pd.get("total_demand", 0)):
                surplus_regions  += 1
            elif float(pd.get("total_demand", 0)) > float(pd.get("total_supply", 0)):
                shortage_regions += 1

        total_supply_entries = surplus_regions + shortage_regions
        surplus_index = round(
            (surplus_regions / total_supply_entries * 100) if total_supply_entries else 0, 1
        )

        stats = {
            "totalFarmers":        platform["totalFarmers"],
            "totalCrops":          platform["totalCrops"],
            "totalOrders":         platform["totalOrders"],
            "totalRevenue":        platform["totalRevenue"],
            "surplusRegions":      surplus_regions,
            "shortageRegions":     shortage_regions,
            "nationalSurplusIndex": surplus_index,
            "cropDistribution":    platform["cropDistribution"],
        }

        # Cache to Firestore
        ref.set({**stats, "updatedAt": datetime.now(timezone.utc).isoformat()})
        return stats
