<<<<<<< HEAD
from dataclasses import dataclass, asdict
from typing import Optional
from passlib.hash import bcrypt

@dataclass
class UserModel:
    id: str
    name: str
    email: str
    role: str           # "farmer" | "buyer" | "officer"
    phone: Optional[str]
    hashed_password: str

    @staticmethod
    def hash_password(password: str) -> str:
        return bcrypt.hash(password)

    @staticmethod
    def verify_password(password: str, hashed: str) -> bool:
        return bcrypt.verify(password, hashed)

    def to_dict(self) -> dict:
        d = asdict(self)
        d.pop("hashed_password", None)
        return d
=======
# backend/models/user_model.py
from dataclasses import dataclass
from typing import Optional
from utils.helpers import ts_to_iso

@dataclass
class UserModel:
    uid:              str
    email:            str
    name:             Optional[str]  = None
    phone_no:         Optional[str]  = None
    location:         Optional[str]  = None
    profile_photo_url: Optional[str] = None
    role:             str            = "farmer"   # farmer | buyer | officer
    fcm_token:        Optional[str]  = None

    def to_dict(self) -> dict:
        return {
            "uid":             self.uid,
            "email":           self.email,
            "name":            self.name,
            "phoneNo":         self.phone_no,
            "location":        self.location,
            "profilePhotoUrl": self.profile_photo_url,
            "role":            self.role,
        }

    @classmethod
    def from_firestore(cls, doc_id: str, data: dict) -> "UserModel":
        return cls(
            uid=              doc_id,
            email=            data.get("email", ""),
            name=             data.get("name"),
            phone_no=         data.get("phoneNo"),
            location=         data.get("location"),
            profile_photo_url=data.get("profilePhotoUrl"),
            role=             data.get("role", "farmer"),
            fcm_token=        data.get("fcmToken"),
        )
>>>>>>> ddbef5e9db3a8e5ea8f1ef25cdf5bcfa36295850
