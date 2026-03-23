# backend/models/analytics_model.py
from dataclasses import dataclass, field

@dataclass
class AnalyticsModel:
    total_crops:       int
    total_orders:      int
    total_revenue:     float
    crop_distribution: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "totalCrops":       self.total_crops,
            "totalOrders":      self.total_orders,
            "totalRevenue":     round(self.total_revenue, 2),
            "cropDistribution": self.crop_distribution,
        }
