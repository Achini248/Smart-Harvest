# backend/database.py
# Smart Harvest — Firebase Admin SDK Initialisation

import os
import firebase_admin
from firebase_admin import credentials, firestore, auth, messaging

_db = None


def init_firebase(app) -> None:
    """Initialise Firebase Admin SDK once at startup."""
    global _db

    # Already initialised (e.g. reloaded in debug mode)
    if firebase_admin._apps:
        _db = firestore.client()
        return

    cred_path = app.config.get("FIREBASE_CREDENTIALS", "serviceAccountKey.json")

    # ── Option 1: Service Account Key file (local dev + production) ──────────
    if cred_path and os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        app.logger.info(f"✅ Firebase initialised with service account: {cred_path}")

    # ── Option 2: Application Default Credentials (GCP / Cloud Run only) ─────
    elif os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        firebase_admin.initialize_app()
        app.logger.info("✅ Firebase initialised with GOOGLE_APPLICATION_CREDENTIALS")

    # ── No credentials found — fail fast with a helpful message ──────────────
    else:
        raise FileNotFoundError(
            "\n\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "  Firebase credentials not found!\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "  Steps to fix:\n"
            "  1. Go to https://console.firebase.google.com\n"
            "  2. Open your project → ⚙️ Project Settings → Service accounts\n"
            "  3. Click 'Generate new private key' and save the .json file\n"
            f"  4. Place it at:  {os.path.abspath(cred_path)}\n"
            "     OR set FIREBASE_CREDENTIALS=/path/to/your/key.json in .env\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        )

    _db = firestore.client()
    app.logger.info("✅ Firestore client ready")


def get_db():
    """Return the Firestore client (module-level singleton, safe in any context)."""
    if _db is None:
        raise RuntimeError("Firestore not initialised. Call init_firebase() first.")
    return _db


def verify_firebase_token(id_token: str) -> dict:
    """
    Verify a Firebase ID token sent from the Flutter app.
    Returns the decoded token payload (uid, email, role claim, etc.)
    Raises firebase_admin.auth.InvalidIdTokenError on failure.
    """
    return auth.verify_id_token(id_token)


def send_push_notification(token: str, title: str, body: str, data: dict = None) -> str:
    """
    Send a single FCM push notification.
    Returns the FCM message ID.
    """
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data={str(k): str(v) for k, v in (data or {}).items()},
        token=token,
    )
    return messaging.send(message)


def send_push_to_topic(topic: str, title: str, body: str, data: dict = None) -> str:
    """Send a push notification to all subscribers of a topic."""
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data={str(k): str(v) for k, v in (data or {}).items()},
        topic=topic,
    )
    return messaging.send(message)
