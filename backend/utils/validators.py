# backend/utils/validators.py
import re

def is_valid_email(email: str) -> bool:
    return bool(re.match(r"^[\w.+-]+@[\w-]+\.[a-z]{2,}$", email, re.I))

def is_valid_phone(phone: str) -> bool:
    return bool(re.match(r"^\+?[\d\s\-]{7,15}$", phone))

def require_fields(data: dict, fields: list) -> list:
    """Return list of missing required fields."""
    return [f for f in fields if not data.get(f)]
