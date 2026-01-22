from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from core.db import get_db
from models.user import User
from services.google_auth import verify_firebase_id_token
from services.auth_service import create_access_token, create_refresh_token
from schemas.auth_google import GoogleLoginRequest

router = APIRouter(
    prefix="/auth",
    tags=["Auth Google"],
)


@router.post("/google")
def google_login(
    data: GoogleLoginRequest,
    db: Session = Depends(get_db),
):
    id_token = data.id_token
    # 1 Verify Firebase ID Token
    try:
        payload = verify_firebase_id_token(id_token)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google token",
        )

    email = payload.get("email")
    name = payload.get("name")

    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email not found in Google token",
        )

    # 2️ Tìm user theo email
    user = db.query(User).filter(User.email == email).first()

    # 3️ Nếu chưa có user → tạo mới
    if not user:
        user = User(
            email=email,
            full_name=name,
            is_active=True,
            auth_provider="google",   # cần có field này
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    # 4️ Tạo JWT access + refresh
    access_token = create_access_token(user.id, user.role)
    refresh_token = create_refresh_token(db, user.id)

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
    }
