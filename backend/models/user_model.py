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
