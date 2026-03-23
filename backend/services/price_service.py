# backend/services/price_service.py
# Smart Harvest — Price Service (Firestore + ML Forecasting)

from collections import defaultdict
from datetime import date, timedelta
from flask import current_app
from database import get_db
from price_service.forecast_model import PriceForecaster, WFPDataLoader


class PriceService:

    # ── Today's Prices ────────────────────────────────────────────────────────
    @staticmethod
    def get_today_prices() -> list[dict]:
        today = date.today().isoformat()
        db    = get_db()

        # Forecast lookup {crop_name: predicted_price}
        forecasts = {}
        for doc in db.collection("price_forecasts") \
                     .where("forecast_date", "==", today).stream():
            d = doc.to_dict()
            forecasts[d.get("crop_name", "")] = float(d.get("predicted_price", 0))

        prices = []
        for doc in db.collection("daily_prices") \
                     .where("date", "==", today).stream():
            row = doc.to_dict()
            row["id"] = doc.id          # ← Firestore document ID for Flutter
            row["predictedPrice"] = (
                row.get("predicted_price") or
                forecasts.get(row.get("crop_name", ""))
            )
            row["isSurplus"]  = float(row.get("total_supply", 0)) > float(row.get("total_demand", 0))
            row["isShortage"] = float(row.get("total_demand", 0)) > float(row.get("total_supply", 0))
            row["avgPrice"]   = row.get("avg_price", 0)
            row["minPrice"]   = row.get("min_price", 0)
            row["maxPrice"]   = row.get("max_price", 0)
            row["cropName"]   = row.get("crop_name", "")
            row["marketName"] = row.get("market_name", "")
            prices.append(row)

        prices.sort(key=lambda x: float(x.get("avgPrice", 0)), reverse=True)
        return prices

    # ── Price History ─────────────────────────────────────────────────────────
    @staticmethod
    def get_price_history(crop_name: str, days: int = 30) -> list[dict]:
        since = (date.today() - timedelta(days=days)).isoformat()
        db    = get_db()

        docs = (
            db.collection("daily_prices")
              .where("crop_name", "==", crop_name)
              .where("date",      ">=", since)
              .stream()
        )

        buckets: dict[str, list[float]] = defaultdict(list)
        for doc in docs:
            row = doc.to_dict()
            buckets[row["date"]].append(float(row.get("avg_price", 0)))

        return [
            {"date": d, "avg_price": round(sum(v) / len(v), 2)}
            for d, v in sorted(buckets.items())
        ]

    # ── Supply Status ─────────────────────────────────────────────────────────
    @staticmethod
    def get_supply_status() -> dict:
        today    = date.today().isoformat()
        db       = get_db()
        surplus = shortage = normal = 0

        for doc in db.collection("daily_prices").where("date", "==", today).stream():
            row = doc.to_dict()
            s   = float(row.get("total_supply", 0))
            d2  = float(row.get("total_demand", 0))
            if s > d2:   surplus  += 1
            elif d2 > s: shortage += 1
            else:        normal   += 1

        total = surplus + shortage + normal
        return {
            "total_surplus":  surplus,
            "total_shortage": shortage,
            "total_normal":   normal,
            "total":          total,
        }

    # ── Government Summary ────────────────────────────────────────────────────
    @staticmethod
    def get_government_summary() -> dict:
        week_ago = (date.today() - timedelta(days=7)).isoformat()
        today    = date.today().isoformat()
        db       = get_db()

        docs = (
            db.collection("daily_prices")
              .where("date", ">=", week_ago)
              .where("date", "<=", today)
              .stream()
        )

        cat_data: dict[str, dict] = defaultdict(lambda: {
            "prices": [], "mins": [], "maxs": [],
            "supply": 0.0, "demand": 0.0,
        })
        tot_surplus = tot_shortage = tot_records = 0

        for doc in docs:
            row    = doc.to_dict()
            cat    = row.get("category", "Other")
            avg    = float(row.get("avg_price",    0))
            mn     = float(row.get("min_price",    0))
            mx     = float(row.get("max_price",    0))
            supply = float(row.get("total_supply", 0))
            demand = float(row.get("total_demand", 0))

            cat_data[cat]["prices"].append(avg)
            cat_data[cat]["mins"].append(mn)
            cat_data[cat]["maxs"].append(mx)
            cat_data[cat]["supply"] += supply
            cat_data[cat]["demand"] += demand

            if supply > demand:   tot_surplus  += 1
            elif demand > supply: tot_shortage += 1
            tot_records += 1

        by_cat = [
            {
                "category":     cat,
                "avg_price":    round(sum(d["prices"]) / max(len(d["prices"]), 1), 2),
                "min_price":    round(min(d["mins"]),  2) if d["mins"] else 0,
                "max_price":    round(max(d["maxs"]),  2) if d["maxs"] else 0,
                "total_supply": d["supply"],
                "total_demand": d["demand"],
            }
            for cat, d in sorted(
                cat_data.items(),
                key=lambda kv: sum(kv[1]["prices"]) / max(len(kv[1]["prices"]), 1),
                reverse=True,
            )
        ]

        return {
            "period":      {"from": week_ago, "to": today},
            "by_category": by_cat,
            "overall": {
                "total_surplus":  tot_surplus,
                "total_shortage": tot_shortage,
                "total_records":  tot_records,
            },
        }


class ForecastService:

    # Cache of per-crop forecasters
    _forecasters: dict[str, PriceForecaster] = {}

    @classmethod
    def _get_forecaster(cls, crop_name: str) -> PriceForecaster:
        if crop_name not in cls._forecasters:
            cls._forecasters[crop_name] = PriceForecaster(crop_name)
        return cls._forecasters[crop_name]

    @classmethod
    def get_or_generate_forecast(cls, crop_name: str) -> dict:
        """
        1. Try to load historical data from WFP CSV (real data).
        2. Fall back to Firestore daily_prices if CSV not available.
        3. Train model and return 7-day forecast.
        """
        min_days = current_app.config.get("MIN_HISTORY_DAYS", 7)
        n_days   = current_app.config.get("FORECAST_DAYS",    7)

        # ── Try WFP CSV data first ──────────────────────────────────────────
        csv_path = current_app.config.get("WFP_DATA_PATH", "")
        history  = []

        if csv_path:
            wfp = WFPDataLoader.load(csv_path)
            if crop_name in wfp:
                history = [
                    {"date": d, "avg_price": p}
                    for d, p in wfp[crop_name]
                ]

        # ── Fall back to Firestore ─────────────────────────────────────────
        if len(history) < min_days:
            history = PriceService.get_price_history(crop_name, days=90)

        if len(history) < min_days:
            return {
                "crop_name":               crop_name,
                "error":                   f"Insufficient data (need {min_days}+ days)",
                "next_7_days_predictions": [],
                "percentage_change":       0.0,
            }

        prices = [h["avg_price"] for h in history]
        dates  = [h["date"]      for h in history]

        forecaster  = cls._get_forecaster(crop_name)
        predictions = forecaster.train_and_predict(prices, dates, n_days=n_days)

        last_actual   = prices[-1]
        last_forecast = predictions[-1]["predicted_price"]
        pct_change    = (
            (last_forecast - last_actual) / last_actual * 100
            if last_actual else 0.0
        )

        cls._save_forecasts(crop_name, predictions)

        return {
            "crop_name":               crop_name,
            "next_7_days_predictions": predictions,
            "percentage_change":       round(pct_change, 2),
        }

    @staticmethod
    def _save_forecasts(crop_name: str, predictions: list[dict]) -> None:
        db = get_db()
        for pred in predictions:
            doc_id = f"{crop_name.lower().replace(' ', '_')}_{pred['date']}"
            db.collection("price_forecasts").document(doc_id).set(
                {
                    "crop_name":       crop_name,
                    "forecast_date":   pred["date"],
                    "predicted_price": pred["predicted_price"],
                },
                merge=True,
            )
