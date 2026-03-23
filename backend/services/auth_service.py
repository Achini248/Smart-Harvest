# backend/services/auth_service.py
# Smart Harvest — Auth Service
# Note: Authentication itself is handled by Firebase Auth in the Flutter app.
# This service manages user profiles stored in Firestore.

from datetime import datetime, timezone
from database import get_db
from firebase_admin import auth
from models.user_model import UserModel


class AuthService:

    @staticmethod
    def get_or_create_profile(uid: str, email: str, name: str = None) -> dict:
        """
        Called after Firebase login.
        Creates a Firestore user profile if it doesn't exist yet.
        """
        db  = get_db()
        ref = db.collection("users").document(uid)
        doc = ref.get()

        if doc.exists:
            return UserModel.from_firestore(uid, doc.to_dict()).to_dict()

        # First-time login — create profile
        now  = datetime.now(timezone.utc).isoformat()
        data = {
            "email":     email,
            "name":      name or email.split("@")[0],
            "role":      "farmer",
            "createdAt": now,
            "updatedAt": now,
        }
        ref.set(data)
        return UserModel.from_firestore(uid, data).to_dict()

    @staticmethod
    def get_profile(uid: str) -> dict | None:
        db  = get_db()
        doc = db.collection("users").document(uid).get()
        if not doc.exists:
            return None
        return UserModel.from_firestore(uid, doc.to_dict()).to_dict()

    @staticmethod
    def update_profile(uid: str, updates: dict) -> dict:
        """Update allowed profile fields."""
        allowed = {"name", "phoneNo", "location", "profilePhotoUrl", "fcmToken"}
        clean   = {k: v for k, v in updates.items() if k in allowed}
        clean["updatedAt"] = datetime.now(timezone.utc).isoformat()

        db  = get_db()
        ref = db.collection("users").document(uid)
        ref.update(clean)

        doc = ref.get()
        return UserModel.from_firestore(uid, doc.to_dict()).to_dict()

    @staticmethod
    def set_role(uid: str, role: str) -> None:
        """
        Set a custom role claim on the Firebase Auth token.
        Roles: farmer | buyer | officer
        """
        auth.set_custom_user_claims(uid, {"role": role})
        # Also persist to Firestore for querying
        get_db().collection("users").document(uid).update({"role": role})

    @staticmethod
    def delete_account(uid: str) -> None:
        """Delete Firebase Auth account and Firestore profile."""
        auth.delete_user(uid)
        get_db().collection("users").document(uid).delete()
