# backend/price_service/forecast_model.py
# Smart Harvest — AI Price Forecast Model
#
# Trained on WFP food prices data for Sri Lanka (wfp_food_prices_lka.csv)
# 23,769 records | 42 commodities | 44 markets | 2004–2025
#
# Model: RandomForestRegressor with 8 engineered time-series features.
# Fallback: LinearRegression for crops with < 30 data points.

import os
import numpy as np
import pandas as pd
import joblib
from datetime import date, timedelta
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import LinearRegression

MODEL_DIR = os.path.join(os.path.dirname(__file__), "models")
os.makedirs(MODEL_DIR, exist_ok=True)

# ── WFP CSV → App crop name mapping ──────────────────────────────────────────
# Keys are EXACT commodity names as they appear in the CSV.
COMMODITY_MAP = {
    # Vegetables
    "Tomatoes":                  "Tomato",
    "Carrots":                   "Carrot",
    "Potatoes (local)":          "Potato",
    "Potatoes (imported)":       "Potato",
    "Onions (red, local)":       "Red Onion",
    "Onions (red, imported)":    "Red Onion",
    "Onions (imported)":         "Red Onion",
    "Onions (red)":              "Red Onion",
    "Cabbage":                   "Cabbage",
    "Beans":                     "Beans",
    "Beans (mung)":              "Green Gram",
    "Eggplants":                 "Eggplant",
    "Pumpkin":                   "Pumpkin",
    "Snake gourd":               "Snake Gourd",
    "Cowpeas (whole, average)":  "Cowpeas",
    "Chili (red, dry raw)":      "Red Chilli",
    # Fruits
    "Bananas":                   "Banana",
    "Papaya":                    "Papaya",
    "Pineapples":                "Pineapple",
    # Grains & Staples
    "Rice (white)":              "Rice",
    "Rice (medium grain)":       "Rice",
    "Rice (red nadu)":           "Rice",
    "Rice (long grain)":         "Rice",
    "Wheat flour":               "Wheat Flour",
    # Protein
    "Lentils":                   "Lentils",
    "Eggs":                      "Eggs",
    "Meat (chicken, broiler)":   "Chicken",
    # Fish
    "Fish (dry, sprats)":        "Dried Sprats",
    "Fish (dry, katta)":         "Dried Fish",
    "Fish (jack)":               "Jack Fish",
    # Other
    "Coconut":                   "Coconut",
    "Sugar":                     "Sugar",
}


class PriceForecaster:
    """
    Trains on monthly WFP price data and predicts next N days.

    Features (8 total):
        day_index      — sequential integer (captures overall price trend)
        lag_1          — previous month price (short-term momentum)
        lag_3          — 3-month lag (quarterly pattern)
        lag_6          — 6-month lag (seasonal pattern)
        rolling_6_mean — 6-month smoothed price level
        rolling_6_std  — 6-month price volatility
        month_sin      — seasonal encoding (circular sin)
        month_cos      — seasonal encoding (circular cos)
    """

    def __init__(self, crop_name: str = "default"):
        self.crop_name   = crop_name
        safe_name        = crop_name.lower().replace(" ", "_").replace("(", "").replace(")", "")
        self._model_path = os.path.join(MODEL_DIR, f"model_{safe_name}.joblib")
        self._model      = None
        self._load()

    # ── Public API ────────────────────────────────────────────────────────────
    def train_and_predict(
        self,
        prices:       list[float],
        date_strings: list[str],
        n_days:       int = 7,
    ) -> list[dict]:
        """
        Train on historical prices and predict the next n_days.

        Args:
            prices:       Chronological avg prices in LKR/kg.
            date_strings: Matching ISO date strings (YYYY-MM-DD).
            n_days:       Days ahead to forecast (default 7).

        Returns:
            [{"date": "2025-10-01", "predicted_price": 245.50}, ...]
        """
        arr   = np.array(prices, dtype=np.float64)
        n     = len(arr)
        dates = [date.fromisoformat(d[:10]) for d in date_strings]

        if n >= 30:
            X, y = self._build_features(arr, dates)
            self._model = RandomForestRegressor(
                n_estimators=200,
                max_depth=10,
                min_samples_leaf=2,
                random_state=42,
                n_jobs=-1,
            )
            self._model.fit(X, y)
            preds = self._iterative_predict(arr, dates, n_days)
        else:
            # Simple linear regression for small datasets
            X = np.arange(n).reshape(-1, 1).astype(np.float64)
            m = LinearRegression().fit(X, arr)
            self._model = m
            preds = m.predict(
                np.arange(n, n + n_days).reshape(-1, 1).astype(np.float64)
            )

        preds = np.clip(preds, a_min=1.0, a_max=None)
        self._save()

        today = date.today()
        return [
            {
                "date":            (today + timedelta(days=i + 1)).isoformat(),
                "predicted_price": round(float(p), 2),
            }
            for i, p in enumerate(preds)
        ]

    # ── Feature Engineering ───────────────────────────────────────────────────
    def _build_features(self, prices: np.ndarray, dates: list) -> tuple:
        n = len(prices)

        day_idx    = np.arange(n, dtype=np.float64)
        lag1       = np.concatenate([[prices[0]] * 1, prices[:-1]])
        lag3       = np.concatenate([[prices[0]] * 3, prices[:-3]])
        lag6       = np.concatenate([[prices[0]] * 6, prices[:-6]])
        roll6_mean = np.array([prices[max(0, i-5):i+1].mean() for i in range(n)])
        roll6_std  = np.array([
            prices[max(0, i-5):i+1].std() if i >= 5 else 0.0 for i in range(n)
        ])
        months    = np.array([d.month for d in dates], dtype=np.float64)
        month_sin = np.sin(2 * np.pi * months / 12)
        month_cos = np.cos(2 * np.pi * months / 12)

        X = np.column_stack([
            day_idx, lag1, lag3, lag6,
            roll6_mean, roll6_std,
            month_sin, month_cos,
        ])
        return X, prices

    def _iterative_predict(
        self, prices: np.ndarray, dates: list, n_days: int
    ) -> np.ndarray:
        """Auto-regressive: each prediction is fed back as the next input."""
        ext_prices = list(prices)
        last_date  = dates[-1]
        preds      = []

        for i in range(n_days):
            next_date = last_date + timedelta(days=i + 1)
            arr  = np.array(ext_prices)
            n    = len(arr)
            lag1 = arr[-1]
            lag3 = arr[-3] if n >= 3 else arr[0]
            lag6 = arr[-6] if n >= 6 else arr[0]
            r6m  = arr[-6:].mean()
            r6s  = arr[-6:].std() if len(arr) >= 6 else 0.0
            m    = next_date.month
            msn  = np.sin(2 * np.pi * m / 12)
            mcs  = np.cos(2 * np.pi * m / 12)

            X    = np.array([[n, lag1, lag3, lag6, r6m, r6s, msn, mcs]])
            pred = float(self._model.predict(X)[0])
            pred = max(pred, 1.0)
            preds.append(pred)
            ext_prices.append(pred)

        return np.array(preds)

    # ── Persistence ───────────────────────────────────────────────────────────
    def _save(self):
        if self._model is not None:
            joblib.dump(self._model, self._model_path, compress=3)

    def _load(self):
        if os.path.exists(self._model_path):
            try:
                self._model = joblib.load(self._model_path)
            except Exception:
                self._model = None


# ── WFP Data Loader ──────────────────────────────────────────────────────────
class WFPDataLoader:
    """
    Loads and processes the WFP food prices CSV for Sri Lanka.

    What it does:
      1. Reads wfp_food_prices_lka.csv
      2. Filters to Retail prices only
      3. Computes monthly national average per commodity (across all markets)
      4. Maps WFP commodity names → app crop names
      5. Merges duplicate mappings (e.g. Potato local + imported → Potato mean)

    Returns 21 years of monthly price data per crop (2004–2025).
    """

    @classmethod
    def load(cls, csv_path: str) -> dict[str, list[dict]]:
        """
        Args:
            csv_path: Absolute path to wfp_food_prices_lka.csv

        Returns:
            {
                "Tomato":    [{"date": "2020-01-01", "avg_price": 85.5}, ...],
                "Carrot":    [...],
                "Red Onion": [...],
                ...
            }
        """
        if not csv_path or not os.path.exists(csv_path):
            return {}

        try:
            df = pd.read_csv(csv_path, low_memory=False)
        except Exception:
            return {}

        # ── Filter & clean ────────────────────────────────────────────────────
        df = df[df["pricetype"] == "Retail"].copy()
        df["price"] = pd.to_numeric(df["price"], errors="coerce")
        df.dropna(subset=["price", "commodity", "date"], inplace=True)
        df = df[df["price"] > 0]

        df["date"] = pd.to_datetime(df["date"], errors="coerce")
        df.dropna(subset=["date"], inplace=True)

        # Only keep commodities we have a mapping for
        df = df[df["commodity"].isin(COMMODITY_MAP.keys())]

        # ── Monthly national average ───────────────────────────────────────────
        # Groups all markets together → one price per commodity per month
        df["month_start"] = df["date"].dt.to_period("M").dt.to_timestamp()

        monthly = (
            df.groupby(["commodity", "month_start"])["price"]
            .mean()
            .reset_index()
            .rename(columns={"month_start": "date", "price": "avg_price"})
        )
        monthly["avg_price"] = monthly["avg_price"].round(2)
        monthly.sort_values(["commodity", "date"], inplace=True)

        # ── Build result dict, merging multi-name crops ───────────────────────
        # E.g. "Potatoes (local)" and "Potatoes (imported)" both → "Potato"
        # We average them per month.
        result: dict[str, dict[str, list]] = {}  # crop_name → {date: [prices]}

        for _, row in monthly.iterrows():
            app_name = COMMODITY_MAP.get(row["commodity"])
            if not app_name:
                continue
            d = row["date"].strftime("%Y-%m-%d")
            p = float(row["avg_price"])

            if app_name not in result:
                result[app_name] = {}
            if d not in result[app_name]:
                result[app_name][d] = []
            result[app_name][d].append(p)

        # Compute final monthly mean and sort chronologically
        final: dict[str, list[dict]] = {}
        for crop, date_prices in result.items():
            final[crop] = [
                {"date": d, "avg_price": round(sum(ps) / len(ps), 2)}
                for d, ps in sorted(date_prices.items())
            ]

        return final

    @classmethod
    def get_available_crops(cls, csv_path: str) -> list[str]:
        """Return all app crop names that have data in the CSV."""
        return sorted(cls.load(csv_path).keys())
