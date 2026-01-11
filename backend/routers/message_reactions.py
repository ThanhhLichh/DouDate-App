from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from core.db import get_db
from core.security import get_current_user_id
from models.message import Message
from models.message_reaction import MessageReaction
from schemas.message_reaction import ReactionRequest

# import chat_manager WS của bạn
from routers.chat import manager as chat_manager

router = APIRouter(prefix="/messages", tags=["Message Reactions"])


@router.post("/{message_id}/reaction")
async def react_message(
    message_id: int,
    data: ReactionRequest,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    message = db.query(Message).filter(Message.id == message_id).first()
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")

    reaction = (
        db.query(MessageReaction)
        .filter(
            MessageReaction.message_id == message_id,
            MessageReaction.user_id == user_id,
        )
        .first()
    )

    # ❌ XOÁ reaction
    if data.emoji is None:
        if reaction:
            db.delete(reaction)
            db.commit()

            await chat_manager.broadcast(
                message.couple_id,
                {
                    "type": "reaction",
                    "message_id": message_id,
                    "user_id": user_id,
                    "emoji": None,
                },
            )

        return {"status": "removed"}

    # 🔁 UPDATE / INSERT
    if reaction:
        reaction.emoji = data.emoji
    else:
        db.add(
            MessageReaction(
                message_id=message_id,
                user_id=user_id,
                emoji=data.emoji,
            )
        )

    db.commit()

    await chat_manager.broadcast(
        message.couple_id,
        {
            "type": "reaction",
            "message_id": message_id,
            "user_id": user_id,
            "emoji": data.emoji,
        },
    )

    return {"status": "ok", "emoji": data.emoji}

