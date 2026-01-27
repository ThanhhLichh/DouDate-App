import hashlib
import secrets
from datetime import datetime, timedelta

from jose import jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from core.config import settings
from models.user import User
from models.refresh_token import RefreshToken
from fastapi import Depends, HTTPException, status  
from core.db import get_db
from core.security import get_current_user_id


# PASSWORD HASHING


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    return pwd_context.verify(password, password_hash)


# JWT CONFIG


ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 15
REFRESH_TOKEN_EXPIRE_DAYS = 30


def create_access_token(user_id: int, role: str) -> str:
    payload = {
        "sub": "doudate-app",     
        "user_id": str(user_id), 
        "role": role,
        "exp": datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=ALGORITHM)




# REFRESH TOKEN


def create_refresh_token(db: Session, user_id: int) -> str:
    raw_token = secrets.token_urlsafe(32)
    token_hash = hashlib.sha256(raw_token.encode()).hexdigest()

    expires_at = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)

    refresh_token = RefreshToken(
        user_id=user_id,
        token_hash=token_hash,
        expires_at=expires_at,
        is_revoked=False,
    )

    db.add(refresh_token)
    db.commit()

    return raw_token


def revoke_refresh_token(db: Session, raw_refresh_token: str):
    token_hash = hashlib.sha256(raw_refresh_token.encode()).hexdigest()

    token = (
        db.query(RefreshToken)
        .filter(RefreshToken.token_hash == token_hash)
        .first()
    )

    if token:
        token.is_revoked = True
        db.commit()


def refresh_access_token(db: Session, raw_refresh_token: str) -> str:
    token_hash = hashlib.sha256(raw_refresh_token.encode()).hexdigest()

    token = (
        db.query(RefreshToken)
        .filter(
            RefreshToken.token_hash == token_hash,
            RefreshToken.is_revoked == False,
            RefreshToken.expires_at > datetime.utcnow(),
        )
        .first()
    )

    if not token:
        raise ValueError("Invalid or expired refresh token")

    user = db.query(User).filter(User.id == token.user_id).first()
    if not user:
        raise ValueError("User not found")

    return create_access_token(user.id, user.role)




# AUTH ACTIONS


def register_user(
    db: Session,
    email: str,
    password: str,
    full_name: str,
) -> User:
    existing_user = db.query(User).filter(User.email == email).first()
    if existing_user:
        raise ValueError("Email already registered")

    user = User(
        email=email,
        password_hash=hash_password(password),
        full_name=full_name,
        is_active=True,
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


def login_user(
    db: Session,
    email: str,
    password: str,
):
    user = db.query(User).filter(User.email == email).first()

    if not user:
        raise ValueError("Invalid email or password")

    if user.auth_provider != "local":
        raise ValueError("Please login with Google")

    if not verify_password(password, user.password_hash):
        raise ValueError("Invalid email or password")


    if not user.is_active:
        raise ValueError("User is inactive")
    
    if user.role != "user":
        print("BLOCK ADMIN LOGIN:", user.email, user.role)
        raise ValueError("Admin must login via web admin")


    access_token = create_access_token(user.id, user.role)
    refresh_token = create_refresh_token(db, user.id)

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
    }

def login_admin(
    db: Session,
    email: str,
    password: str,
):
    user = db.query(User).filter(User.email == email).first()

    if not user:
        raise ValueError("Invalid email or password")

    if user.auth_provider != "local":
        raise ValueError("Please login with Google")

    if not verify_password(password, user.password_hash):
        raise ValueError("Invalid email or password")

    if not user.is_active:
        raise ValueError("User is inactive")

    #  CHỈ CHO ADMIN
    if user.role != "admin":
        raise ValueError("Not an admin account")

    access_token = create_access_token(user.id, user.role)
    refresh_token = create_refresh_token(db, user.id)

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
    }



def get_current_user(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User is banned",
        )

    return user
