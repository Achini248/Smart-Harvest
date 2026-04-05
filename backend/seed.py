# backend/seed.py
# Smart Harvest — Firestore Seed Script
# Run once: python seed.py
# Places serviceAccountKey.json in backend/ first.

import os, hashlib
from datetime import date, timedelta
import firebase_admin
from firebase_admin import credentials, firestore

CRED = os.environ.get("FIREBASE_CREDENTIALS", "serviceAccountKey.json")
if not firebase_admin._apps:
    firebase_admin.initialize_app(credentials.Certificate(CRED))
db = firestore.client()

def day(n): return (date.today() - timedelta(days=n)).isoformat()

def confirm():
    if input("⚠️  Overwrite Firestore data? Type 'yes': ").strip().lower() != "yes":
        exit(0)

def seed_daily_prices():
    records = {
        # Tomato @ Dambulla — Shortage
        "tomato_dambulla": [
            (6,60,90,75,5000,7500),(5,62,92,77,5200,7000),(4,65,95,80,4800,7200),
            (3,68,98,83,4500,7000),(2,70,100,85,4200,7500),(1,72,98,84,4600,6800),(0,70,100,85,4100,7800),
        ],
        # Carrot @ Nuwara Eliya — Surplus
        "carrot_nuwaraeliya": [
            (6,150,210,180,8000,5000),(5,155,215,185,8200,5200),(4,158,218,188,8500,5100),
            (3,160,220,190,9000,5300),(2,162,222,192,8800,5400),(1,165,225,193,9200,5600),(0,165,225,195,9500,5500),
        ],
        # Red Onion @ Colombo — Surplus
        "onion_colombo": [
            (6,100,155,127,6000,4500),(5,105,158,130,6200,4600),(4,108,160,132,6300,4700),
            (3,110,162,135,6400,4800),(2,112,165,137,6500,4900),(1,113,163,138,6450,4850),(0,115,165,140,6600,4800),
        ],
        # Potato @ Kandy — Normal
        "potato_kandy": [
            (6,90,140,115,3000,3000),(5,92,142,117,3100,3100),(4,93,143,118,3050,3050),
            (3,94,144,119,3200,3200),(2,95,145,120,3150,3150),(1,96,145,120,3180,3180),(0,95,148,120,3200,3200),
        ],
    }

    meta = {
        "tomato_dambulla":    ("Tomato",    "Dambulla Economic Centre",  "North Central Province", "Vegetables"),
        "carrot_nuwaraeliya": ("Carrot",    "Nuwara Eliya Market",       "Central Province",       "Vegetables"),
        "onion_colombo":      ("Red Onion", "Colombo Manning Market",    "Western Province",       "Vegetables"),
        "potato_kandy":       ("Potato",    "Kandy Municipal Market",    "Central Province",       "Vegetables"),
    }

    count = 0
    for key, rows in records.items():
        crop_name, market_name, district, category = meta[key]
        for offset, mn, mx, avg, sup, dem in rows:
            doc_id = f"{key}_{day(offset)}"
            db.collection("daily_prices").document(doc_id).set({
                "crop_name":    crop_name,
                "market_name":  market_name,
                "district":     district,
                "category":     category,
                "date":         day(offset),
                "min_price":    float(mn),
                "max_price":    float(mx),
                "avg_price":    float(avg),
                "total_supply": float(sup),
                "total_demand": float(dem),
            })
            count += 1
    print(f"✅ Seeded {count} daily_prices documents")

def seed_dashboard():
    db.collection("dashboard_stats").document("national").set({
        "totalFarmers":        12456,
        "totalCrops":          45230,
        "totalOrders":         2340,
        "totalRevenue":        12500000,
        "surplusRegions":      12,
        "shortageRegions":     3,
        "nationalSurplusIndex": 12.4,
        "cropDistribution":    {"Rice": 45000, "Vegetables": 2300, "Fruits": 1200},
        "updatedAt":           "2020-01-01T00:00:00",  # force recompute on first request
    })
    print("✅ Seeded dashboard_stats/national")

if __name__ == "__main__":
    confirm()
    seed_daily_prices()
    seed_dashboard()
    print("\n✅ Seed complete — Firebase project: smart-harvest-f27d4")
    print("\n⚠️  Create these Firestore composite indexes:")
    print("   daily_prices : crop_name ASC + date ASC")
    print("   daily_prices : date ASC (range)")
    print("   notifications: ownerId ASC + createdAt DESC")
    print("   messages     : conversationId ASC + createdAt ASC")
    print("   conversations: participants (array) + lastMessageAt DESC")
    print("   orders       : buyerId ASC + createdAt DESC")
    print("   orders       : sellerId ASC + createdAt DESC")
