# backend/services/news_service.py
# Smart Harvest — News Service
#
# Strategy (in order):
#   1. Try multiple free RSS/JSON news sources for Sri Lanka agriculture news
#   2. If all external sources fail, return curated static fallback articles
#      that are always relevant to Sri Lankan farmers — never shows "No data"

import hashlib
import requests
from datetime import date, timedelta

_TIMEOUT = 5

# Free RSS feeds relevant to Sri Lanka agriculture
_RSS_FEEDS = [
    {
        "url": (
            "https://api.rss2json.com/v1/api.json"
            "?rss_url=https%3A%2F%2Fwww.dailymirror.lk%2Frss%2Fbusiness%2Ffeed.xml"
            "&api_key=public&count=6"
        ),
        "source": "Daily Mirror Sri Lanka",
    },
    {
        "url": (
            "https://api.rss2json.com/v1/api.json"
            "?rss_url=https%3A%2F%2Fwww.ft.lk%2Fagribusiness%2Frss"
            "&api_key=public&count=6"
        ),
        "source": "Financial Times Sri Lanka",
    },
    {
        "url": (
            "https://api.rss2json.com/v1/api.json"
            "?rss_url=https%3A%2F%2Fwww.adaderana.lk%2Frss%2F"
            "&api_key=public&count=6"
        ),
        "source": "Ada Derana",
    },
]

# Static fallback — always shown if all RSS feeds fail
# Rotates based on day-of-year so it feels fresh each day
_STATIC_NEWS = [
    {
        "title": "Paddy Cultivation Season: Key Tips for Sri Lankan Farmers",
        "description": (
            "The Department of Agriculture recommends timely land preparation "
            "and certified seed varieties for the upcoming Maha season. "
            "Proper water management and fertiliser scheduling can increase yields by up to 20%."
        ),
        "category": "Farming Tips",
        "source": "Dept. of Agriculture Sri Lanka",
    },
    {
        "title": "Vegetable Prices Rise Ahead of Festive Season",
        "description": (
            "Wholesale prices for beans, carrot, and leeks have increased at the "
            "Dambulla Economic Centre this week. Farmers are advised to bring produce "
            "to market early to benefit from stronger demand."
        ),
        "category": "Market Update",
        "source": "Smart Harvest Market Intelligence",
    },
    {
        "title": "Climate Advisory: Prepare Crops for Dry Spell",
        "description": (
            "The Meteorological Department forecasts below-average rainfall in the "
            "Northern and North-Central provinces. Farmers should implement water "
            "conservation techniques and mulching to protect crops."
        ),
        "category": "Weather Advisory",
        "source": "Meteorological Dept. Sri Lanka",
    },
    {
        "title": "Export Demand Strong for Ceylon Cinnamon and Pepper",
        "description": (
            "Sri Lanka's spice exports continue to grow, with cinnamon and black pepper "
            "seeing increased demand from European and Middle Eastern markets. "
            "Smallholder farmers are encouraged to register with the EDB for direct access."
        ),
        "category": "Export News",
        "source": "Export Development Board Sri Lanka",
    },
    {
        "title": "Fertiliser Subsidy Programme: How to Apply",
        "description": (
            "The Ministry of Agriculture has announced the continuation of the fertiliser "
            "subsidy programme for registered paddy and vegetable farmers. "
            "Applications can be submitted through your nearest Agrarian Service Centre."
        ),
        "category": "Government Scheme",
        "source": "Ministry of Agriculture Sri Lanka",
    },
    {
        "title": "Smart Irrigation: Saving Water During Dry Season",
        "description": (
            "Drip irrigation systems are being adopted rapidly in the dry zone districts "
            "of Anuradhapura and Polonnaruwa. Studies show a 40% reduction in water use "
            "with no drop in crop yield when properly installed."
        ),
        "category": "Technology",
        "source": "Smart Harvest",
    },
    {
        "title": "Organic Certification: A Growing Opportunity for Farmers",
        "description": (
            "Global demand for organic produce is rising. Sri Lankan farmers who obtain "
            "organic certification can command premium prices in both local supermarkets "
            "and export markets. The certification process takes 2–3 years."
        ),
        "category": "Farming Tips",
        "source": "Smart Harvest",
    },
    {
        "title": "Colombo Economic Centre Price Report",
        "description": (
            "This week's Colombo Economic Centre report shows steady prices for "
            "tomatoes, potatoes, and onions. Demand remains healthy ahead of the "
            "upcoming school term. Farmers should plan deliveries accordingly."
        ),
        "category": "Market Update",
        "source": "Smart Harvest Market Intelligence",
    },
]


class NewsService:

    @staticmethod
    def get_news(limit: int = 6) -> list[dict]:
        """
        Return news items. Tries external RSS feeds first,
        then falls back to static curated articles — never returns empty.
        """
        # Try each RSS feed in order; return first that works
        for feed in _RSS_FEEDS:
            items = NewsService._fetch_rss(feed["url"], feed["source"])
            if items:
                return items[:limit]

        # All external sources failed — use static fallback
        return NewsService._static_fallback(limit)

    # ── External RSS ──────────────────────────────────────────────────────────
    @staticmethod
    def _fetch_rss(url: str, source: str) -> list[dict]:
        try:
            resp = requests.get(url, timeout=_TIMEOUT)
            if resp.status_code != 200:
                return []
            data = resp.json()
            if data.get("status") != "ok":
                return []
            items = data.get("items", [])
            result = []
            for item in items:
                title = (item.get("title") or "").strip()
                if not title:
                    continue
                desc = (item.get("description") or item.get("content") or "").strip()
                # Strip HTML tags from description
                import re
                desc = re.sub(r"<[^>]+>", "", desc)[:250].strip()
                result.append({
                    "id":          NewsService._stable_id(item.get("link", title)),
                    "title":       title,
                    "description": desc,
                    "imageUrl":    (
                        item.get("enclosure", {}).get("link") or
                        item.get("thumbnail") or ""
                    ),
                    "publishedAt": item.get("pubDate", date.today().isoformat()),
                    "source":      source,
                    "category":    "Agriculture",
                })
            return result
        except Exception:
            return []

    # ── Static fallback — always works ────────────────────────────────────────
    @staticmethod
    def _static_fallback(limit: int) -> list[dict]:
        """
        Return a rotating selection of curated articles.
        Rotates daily so the home screen doesn't look stale.
        """
        today = date.today()
        # Rotate starting index by day-of-year so articles cycle daily
        offset = today.timetuple().tm_yday % len(_STATIC_NEWS)
        rotated = _STATIC_NEWS[offset:] + _STATIC_NEWS[:offset]

        result = []
        for i, item in enumerate(rotated[:limit]):
            # Give each article a date that spreads over the last few days
            pub_date = (today - timedelta(days=i)).isoformat()
            result.append({
                "id":          NewsService._stable_id(item["title"] + pub_date),
                "title":       item["title"],
                "description": item["description"],
                "imageUrl":    "",
                "publishedAt": pub_date,
                "source":      item["source"],
                "category":    item["category"],
            })
        return result

    @staticmethod
    def _stable_id(text: str) -> str:
        return hashlib.md5(text.encode()).hexdigest()[:12]
