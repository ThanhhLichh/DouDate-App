from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from jose import jwt, JWTError


from core.db import get_db
from core.config import settings
from core.security import get_current_user_id


from services.qr_service import (
    create_qr,
    scan_qr,
    respond_qr,
)

from schemas.qr import (
    QrCreateResponse,
    QrScanRequest,
    QrScanResponse,
    QrRespondRequest,
    CoupleResponse,
)



router = APIRouter(
    prefix="/qr",
    tags=["QR"],
)

# CREATE QR
@router.post(
    "/create",
    response_model=QrCreateResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_qr_endpoint(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    try:
        return create_qr(db, user_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )

# SCAN QR

@router.post(
    "/scan",
    response_model=QrScanResponse,
)
def scan_qr_endpoint(
    data: QrScanRequest,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    try:
        return scan_qr(db, data.token, user_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )

# RESPOND QR (ACCEPT / REJECT)

@router.post(
    "/respond",
    response_model=CoupleResponse | None,
)
def respond_qr_endpoint(
    data: QrRespondRequest,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    try:
        result = respond_qr(
            db=db,
            token=data.token,
            user_id=user_id,
            action=data.action,
        )
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )




