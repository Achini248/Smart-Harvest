<<<<<<< HEAD
import re

def is_valid_email(email: str) -> bool:
    pattern = r"^[\w\.-]+@[\w\.-]+\.\w{2,}$"
    return bool(re.match(pattern, email or ""))

def is_strong_password(password: str) -> bool:
    # Simplified: at least 6 chars
    return isinstance(password, str) and len(password) >= 6

def require_fields(data: dict, fields: list[str]) -> list[str]:
    missing = []
    for f in fields:
        if f not in data or data[f] in (None, "", []):
            missing.append(f)
    return missing
=======
# backend/utils/validators.py
import re

def is_valid_email(email: str) -> bool:
    return bool(re.match(r"^[\w.+-]+@[\w-]+\.[a-z]{2,}$", email, re.I))

def is_valid_phone(phone: str) -> bool:
    return bool(re.match(r"^\+?[\d\s\-]{7,15}$", phone))

def require_fields(data: dict, fields: list) -> list:
    """Return list of missing required fields."""
    return [f for f in fields if not data.get(f)]
>>>>>>> ddbef5e9db3a8e5ea8f1ef25cdf5bcfa36295850
