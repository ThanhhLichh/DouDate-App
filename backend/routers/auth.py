from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from core.db import get_db
from schemas.auth import (
    RegisterRequest,
    LoginRequest,
    TokenResponse,
    RefreshRequest,
)
from schemas.user import UserResponse
from services.auth_service import (
    register_user,
    login_user,
    refresh_access_token,
    revoke_refresh_token,
)

router = APIRouter(
    prefix="/auth",
    tags=["Auth"],
)


# REGISTER

@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    try:
        user = register_user(
            db=db,
            email=data.email,
            password=data.password,
            full_name=data.full_name,
        )
        return user
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )



# LOGIN

@router.post(
    "/login",
    response_model=TokenResponse,
)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    try:
        tokens = login_user(
            db=db,
            email=data.email,
            password=data.password,
        )
        return tokens
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
        )



# REFRESH TOKEN

@router.post(
    "/refresh",
    response_model=TokenResponse,
)
def refresh(data: RefreshRequest, db: Session = Depends(get_db)):
    try:
        access_token = refresh_access_token(db, data.refresh_token)
        return {
            "access_token": access_token,
            "refresh_token": data.refresh_token,
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
        )



# LOGOUT

@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(data: RefreshRequest, db: Session = Depends(get_db)):
    revoke_refresh_token(db, data.refresh_token)
    return None
