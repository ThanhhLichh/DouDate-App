import random
from datetime import datetime, timedelta
from jose import jwt, JWTError

from core.config import settings


OTP_EXPIRE_MINUTES = 5
RESET_TOKEN_EXPIRE_MINUTES = 5
ALGORITHM = "HS256"


def generate_otp() -> str:
    return f"{random.randint(100000, 999999)}"


def create_otp_token(email: str, otp: str) -> str:
    payload = {
        "sub": "password_otp",
        "email": email,
        "otp": otp,
        "exp": datetime.utcnow() + timedelta(minutes=OTP_EXPIRE_MINUTES),
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=ALGORITHM)


def verify_otp_token(token: str, email: str, otp: str):
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[ALGORITHM],
        )
    except JWTError:
        raise ValueError("Invalid or expired OTP")

    if payload.get("sub") != "password_otp":
        raise ValueError("Invalid OTP token")

    if payload.get("email") != email:
        raise ValueError("Invalid OTP")

    if payload.get("otp") != otp:
        raise ValueError("Invalid OTP")


def create_reset_token(email: str) -> str:
    payload = {
        "sub": "password_reset",
        "email": email,
        "exp": datetime.utcnow() + timedelta(minutes=RESET_TOKEN_EXPIRE_MINUTES),
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=ALGORITHM)


def verify_reset_token(token: str) -> str:
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[ALGORITHM],
        )
    except JWTError:
        raise ValueError("Invalid or expired reset token")

    if payload.get("sub") != "password_reset":
        raise ValueError("Invalid reset token")

    return payload.get("email")
