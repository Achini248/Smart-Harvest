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
