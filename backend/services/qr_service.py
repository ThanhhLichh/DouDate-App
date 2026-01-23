import uuid
from datetime import datetime, timedelta, date
from routers.qr_socket import qr_manager


from sqlalchemy.orm import Session
from sqlalchemy import or_

from models.qr_token import QrToken
from models.couple_request import CoupleRequest
from models.couple import Couple
from models.user import User



# CONFIG


QR_EXPIRE_MINUTES = 10



# CREATE QR

def create_qr(db: Session, user_id: int):
    # User đã có couple chưa
    existing = (
        db.query(Couple)
        .filter(
            or_(
                Couple.user1_id == user_id,
                Couple.user2_id == user_id,
            ),
            Couple.end_date.is_(None),
        )
        .first()
    )
    if existing:
        raise ValueError("User already has a couple")

    token = str(uuid.uuid4())
    expires_at = datetime.utcnow() + timedelta(minutes=QR_EXPIRE_MINUTES)

    qr = QrToken(
        user_id=user_id,
        token=token,
        expires_at=expires_at,
        is_used=False,
    )

    request = CoupleRequest(
        from_user_id=user_id,
        qr_token=token,
        status="pending",
    )

    db.add(qr)
    db.flush()

    db.add(request)
    db.commit()


    return {
        "token": token,
        "expires_at": expires_at,
    }



# SCAN QR


async def scan_qr(db: Session, token: str, scanner_user_id: int):
    qr = (
        db.query(QrToken)
        .with_for_update()
        .filter(QrToken.token == token)
        .first()
    )

    if not qr:
        raise ValueError("QR not found")

    if qr.is_used:
        raise ValueError("QR already used")

    if qr.expires_at < datetime.utcnow():
        raise ValueError("QR expired")

    if qr.user_id == scanner_user_id:
        raise ValueError("Cannot scan your own QR")

    request = (
        db.query(CoupleRequest)
        .filter(CoupleRequest.qr_token == token)
        .first()
    )

    if not request or request.status != "pending":
        raise ValueError("Invalid QR request")

    user = db.query(User).filter(User.id == qr.user_id).first()

    #  REALTIME EVENT TO USER A
    await qr_manager.notify_qr_scanned(
        qr.user_id,
        {
            "event": "QR_SCANNED",
            "from_user_id": scanner_user_id,
        }
    )

    return {
        "from_user_id": user.id,
        "from_user_name": user.full_name,
        "created_at": request.created_at,
        "expires_at": qr.expires_at,
        "status": request.status,
    }






# RESPOND QR (ACCEPT / REJECT)


async def respond_qr(db: Session, token: str, user_id: int, action: str):
    qr = (
    db.query(QrToken)
    .with_for_update()
    .filter(QrToken.token == token)
    .first()
    )

    if not qr:
        raise ValueError("QR not found")

    request = (
        db.query(CoupleRequest)
        .filter(CoupleRequest.qr_token == token)
        .first()
    )
    if not request or request.status != "pending":
        raise ValueError("QR already handled")

    if qr.user_id == user_id:
        raise ValueError("Cannot respond to your own QR")

    # Người scan đã có couple chưa
    existing = (
        db.query(Couple)
        .filter(
            or_(
                Couple.user1_id == user_id,
                Couple.user2_id == user_id,
            ),
            Couple.end_date.is_(None),
        )
        .first()
    )
    if existing:
        raise ValueError("User already has a couple")

    # REJECT
    if action == "reject":
        request.status = "rejected"
        request.to_user_id = user_id
        qr.is_used = True
        db.commit()

        # 🔔 realtime notify cho người tạo QR
        await qr_manager.notify_qr_scanned(
            qr.user_id,
            {
                "event": "CONNECTION_REJECTED",
                "data": {
                    "message": "Connection declined",
                    "by_user_id": user_id,
                }
            }
        )

        return None


    # ACCEPT
    if action != "accept":
        raise ValueError("Invalid action")

    couple = Couple(
        user1_id=qr.user_id,
        user2_id=user_id,
        start_date=date.today(),
    )

    request.status = "accepted"
    request.to_user_id = user_id
    db.query(QrToken).filter(
        QrToken.user_id == qr.user_id,
        QrToken.is_used == False,
    ).update(
        {"is_used": True},
        synchronize_session=False,
    )

    db.add(couple)
    db.commit()
    db.refresh(couple)

    #  realtime notify cho người tạo QR
    partner = db.query(User).filter(User.id == user_id).first()

    await qr_manager.notify_qr_scanned(
        qr.user_id,
        {
            "event": "CONNECTION_ACCEPTED",
            "data": {
                "partner_id": user_id,
                "partner_name": partner.full_name if partner else None,
                "couple_id": couple.id,
                "start_date": couple.start_date.isoformat(),
            }
        }
    )
    return couple
