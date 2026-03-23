# backend/services/news_service.py
# Smart Harvest — News Service
#
# Strategy (in order):
#   1. Try to fetch Sri Lanka agriculture news from RSS2JSON (free, no key)
#   2. Fall back to dynamic news generated from real Firestore price/surplus data
#
# This ensures news is always real and data-driven — never hardcoded.

import hashlib
import requests
from datetime import date, timedelta
from database import get_db
from services.price_service import PriceService


_RSS_URL = (
    "https://api.rss2json.com/v1/api.json"
    "?rss_url=https%3A%2F%2Fwww.ft.lk%2Fagribusiness%2Frss"
    "&api_key=public"
    "&count=6"
)
_TIMEOUT = 5


class NewsService:

    @staticmethod
    def get_news(limit: int = 6) -> list[dict]:
        """
        Return news items. Tries external RSS feed first,
        then falls back to dynamic crop-price news.
        """
        items = NewsService._fetch_rss()
        if items:
            return items[:limit]
        return NewsService._generate_from_prices(limit)

    # ── External RSS ──────────────────────────────────────────────────────────
    @staticmethod
    def _fetch_rss() -> list[dict]:
        try:
            resp = requests.get(_RSS_URL, timeout=_TIMEOUT)
            if resp.status_code != 200:
                return []
            data  = resp.json()
            items = data.get("items", [])
            result = []
            for item in items:
                result.append({
                    "id":          NewsService._stable_id(item.get("link", "")),
                    "title":       item.get("title", ""),
                    "description": item.get("description", "")[:200].strip(),
                    "imageUrl":    item.get("enclosure", {}).get("link") or item.get("thumbnail", ""),
                    "publishedAt": item.get("pubDate", ""),
                    "source":      "Financial Times Sri Lanka",
                    "category":    "Agriculture",
                })
            return [r for r in result if r["title"]]
        except Exception:
            return []

    # ── Dynamic generation from real price data ───────────────────────────────
    @staticmethod
    def _generate_from_prices(limit: int) -> list[dict]:
        """
        Build news cards from today's market data:
        - Top price movers  → "Market Update" articles
        - Surplus/shortage  → "Supply Alert" articles
        - Forecast hint     → "Forecast" article
        """
        try:
            today_prices = PriceService.get_today_prices()
            supply       = PriceService.get_supply_status()
        except Exception:
            return []

        news: list[dict] = []
        today_str = date.today().strftime("%B %d, %Y")

        # ── Surplus alerts ────────────────────────────────────────────────────
        surplus_crops  = [p for p in today_prices if p.get("isSurplus")]
        shortage_crops = [p for p in today_prices if p.get("isShortage")]

        if surplus_crops:
            names = ", ".join(c["cropName"] for c in surplus_crops[:3])
            news.append({
                "id":          f"surplus_{date.today().isoformat()}",
                "title":       f"Market Surplus: {names}",
                "description": (
                    f"As of {today_str}, supply exceeds demand for {names}. "
                    f"Farmers are advised to consider storage or early sales. "
                    f"Total surplus items today: {supply['total_surplus']}."
                ),
                "imageUrl":    "",
                "publishedAt": date.today().isoformat(),
                "source":      "Smart Harvest Market Intelligence",
                "category":    "Supply Alert",
            })

        if shortage_crops:
            names = ", ".join(c["cropName"] for c in shortage_crops[:3])
            news.append({
                "id":          f"shortage_{date.today().isoformat()}",
                "title":       f"Supply Shortage: {names}",
                "description": (
                    f"Demand is currently outpacing supply for {names} ({today_str}). "
                    f"Prices may rise. Buyers should plan purchases in advance. "
                    f"Total shortage items today: {supply['total_shortage']}."
                ),
                "imageUrl":    "",
                "publishedAt": date.today().isoformat(),
                "source":      "Smart Harvest Market Intelligence",
                "category":    "Supply Alert",
            })

        # ── Top-price crops as market updates ────────────────────────────────
        for p in today_prices[:4]:
            predicted = p.get("predictedPrice")
            avg       = float(p.get("avgPrice", 0))
            if avg == 0:
                continue
            direction = ""
            if predicted and predicted > avg:
                pct = round((predicted - avg) / avg * 100, 1)
                direction = f"AI forecast suggests a {pct}% price increase in the next 7 days."
            elif predicted and predicted < avg:
                pct = round((avg - predicted) / avg * 100, 1)
                direction = f"AI forecast suggests a {pct}% price decrease in the next 7 days."

            news.append({
                "id":          f"price_{p.get('cropName', '').lower().replace(' ', '_')}_{date.today().isoformat()}",
                "title":       f"{p['cropName']} — LKR {avg:.0f}/kg",
                "description": (
                    f"Today's average price for {p['cropName']} is LKR {avg:.0f}/kg "
                    f"(min: {p.get('minPrice', 0):.0f}, max: {p.get('maxPrice', 0):.0f}). "
                    f"{direction}".strip()
                ),
                "imageUrl":    "",
                "publishedAt": date.today().isoformat(),
                "source":      "Smart Harvest Market Intelligence",
                "category":    "Market Update",
            })

        # ── Summary article ───────────────────────────────────────────────────
        total = supply.get("total", 0)
        if total > 0:
            news.append({
                "id":          f"summary_{date.today().isoformat()}",
                "title":       f"Daily Market Summary — {today_str}",
                "description": (
                    f"Smart Harvest tracked {total} crop-market entries today. "
                    f"{supply['total_surplus']} items are in surplus, "
                    f"{supply['total_shortage']} in shortage, "
                    f"and {supply['total_normal']} at normal supply levels."
                ),
                "imageUrl":    "",
                "publishedAt": date.today().isoformat(),
                "source":      "Smart Harvest Market Intelligence",
                "category":    "Daily Summary",
            })

        return news[:limit]

    @staticmethod
    def _stable_id(url: str) -> str:
        return hashlib.md5(url.encode()).hexdigest()[:12]
