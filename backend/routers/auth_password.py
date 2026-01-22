from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from core.db import get_db
from models.user import User
from services.password_reset import (
    generate_otp,
    create_otp_token,
    verify_otp_token,
    create_reset_token,
    verify_reset_token,
)
from services.mail_service import send_otp_email
from services.auth_service import hash_password


from schemas.auth_password import (
    ForgotPasswordRequest,
    VerifyOtpRequest,
    ResetPasswordRequest,
)

router = APIRouter(
    prefix="/auth",
    tags=["Auth Password"],
)


@router.post("/forgot-password")
def forgot_password(
    data: ForgotPasswordRequest,
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.email == data.email).first()

    if user:

        if user.auth_provider == "google":
            return {
                "message": "This account uses Google Sign-In. Please login with Google."
            }
        
        otp = generate_otp()
        token = create_otp_token(data.email, otp)
        send_otp_email(data.email, otp)

        # FE cần giữ token này
        return {
            "otp_token": token,
            "message": "OTP has been sent"
        }

    # không leak email tồn tại hay không
    return {
        "message": "OTP has been sent"
    }


@router.post("/verify-otp")
def verify_otp(data: VerifyOtpRequest):
    try:
        verify_otp_token(
            token=data.token,
            email=data.email,
            otp=data.otp,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    reset_token = create_reset_token(data.email)
    return {
        "reset_token": reset_token
    }


@router.post("/reset-password")
def reset_password(
    data: ResetPasswordRequest,
    db: Session = Depends(get_db),
):
    try:
        email = verify_reset_token(data.reset_token)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user.auth_provider == "google":
        raise HTTPException(
            status_code=400,
            detail="This account uses Google Sign-In. Password cannot be reset."
        )

    user.password_hash = hash_password(data.new_password)
    db.commit()

    return {
        "message": "Password updated successfully"
    }
