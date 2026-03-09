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
