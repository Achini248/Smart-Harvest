<<<<<<< HEAD
from datetime import datetime, timezone
from typing import Optional, Tuple

import jwt
from bson import ObjectId

from config import Config
from database import users_collection
from models.user_model import UserModel
from utils.validators import is_valid_email, is_strong_password
from utils.logger import logger

class AuthService:
    @staticmethod
    def _generate_token(user_id: str) -> str:
        payload = {
            "sub": user_id,
            "iat": datetime.now(timezone.utc),
            "exp": datetime.now(timezone.utc) + Config.JWT_ACCESS_TOKEN_EXPIRES,
        }
        return jwt.encode(payload, Config.JWT_SECRET_KEY, algorithm=Config.JWT_ALGORITHM)

    @staticmethod
    def decode_token(token: str) -> Optional[str]:
        try:
            decoded = jwt.decode(
                token,
                Config.JWT_SECRET_KEY,
                algorithms=[Config.JWT_ALGORITHM],
            )
            return decoded.get("sub")
        except jwt.PyJWTError as e:
            logger.warning(f"Invalid token: {e}")
            return None

    @staticmethod
    def register_user(
        name: str,
        email: str,
        password: str,
        role: str = "farmer",
        phone: Optional[str] = None,
    ) -> Tuple[Optional[dict], Optional[str]]:
        if not is_valid_email(email):
            return None, "Invalid email format."
        if not is_strong_password(password):
            return None, "Password too weak."

        existing = users_collection.find_one({"email": email.lower()})
        if existing:
            return None, "Email already registered."

        hashed = UserModel.hash_password(password)
        doc = {
            "name": name,
            "email": email.lower(),
            "role": role,
            "phone": phone,
            "password_hash": hashed,
            "created_at": datetime.utcnow(),
        }
        result = users_collection.insert_one(doc)
        user = {
            "id": str(result.inserted_id),
            "name": name,
            "email": email.lower(),
            "role": role,
            "phone": phone,
        }
        token = AuthService._generate_token(user["id"])
        return {"user": user, "token": token}, None

    @staticmethod
    def login_user(email: str, password: str) -> Tuple[Optional[dict], Optional[str]]:
        if not is_valid_email(email):
            return None, "Invalid email or password."

        doc = users_collection.find_one({"email": email.lower()})
        if not doc:
            return None, "Invalid email or password."

        if not UserModel.verify_password(password, doc["password_hash"]):
            return None, "Invalid email or password."

        user = {
            "id": str(doc["_id"]),
            "name": doc["name"],
            "email": doc["email"],
            "role": doc["role"],
            "phone": doc.get("phone"),
        }
        token = AuthService._generate_token(user["id"])
        return {"user": user, "token": token}, None

    @staticmethod
    def get_user_by_id(user_id: str) -> Optional[dict]:
        try:
            doc = users_collection.find_one({"_id": ObjectId(user_id)})
        except Exception:
            return None
        if not doc:
            return None
        return {
            "id": str(doc["_id"]),
            "name": doc["name"],
            "email": doc["email"],
            "role": doc["role"],
            "phone": doc.get("phone"),
        }
=======
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
>>>>>>> ddbef5e9db3a8e5ea8f1ef25cdf5bcfa36295850
