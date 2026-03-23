# backend/models/price_model.py
from dataclasses import dataclass
from typing import Optional

@dataclass
class PriceModel:
    crop_name:       str
    market_name:     str
    district:        str
    category:        str
    date:            str
    min_price:       float
    max_price:       float
    avg_price:       float
    total_supply:    float
    total_demand:    float
    predicted_price: Optional[float] = None

    @property
    def is_surplus(self):  return self.total_supply > self.total_demand
    @property
    def is_shortage(self): return self.total_demand > self.total_supply

    def to_dict(self) -> dict:
        return {
            "cropName":       self.crop_name,
            "marketName":     self.market_name,
            "district":       self.district,
            "category":       self.category,
            "date":           self.date,
            "minPrice":       round(self.min_price, 2),
            "maxPrice":       round(self.max_price, 2),
            "avgPrice":       round(self.avg_price, 2),
            "totalSupply":    self.total_supply,
            "totalDemand":    self.total_demand,
            "predictedPrice": round(self.predicted_price, 2) if self.predicted_price else None,
            "isSurplus":      self.is_surplus,
            "isShortage":     self.is_shortage,
        }
