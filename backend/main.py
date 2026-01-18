from fastapi import FastAPI
from core.config import settings
from routers.auth import router as auth_router
from routers.qr import router as qr_router
from routers.couple import router as couple_router
from routers.chat import router as chat_router
from routers.messages import router as messages_router
from routers.moments import router as moments_router
from routers.memories import router as memories_router
from routers.users import router as users_router
from routers.qr_socket import router as qr_socket_router
from routers import message_reactions
from routers.admin import users as admin_users
from routers.admin import couples as admin_couples
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI(
    title=settings.APP_NAME,
    debug=settings.DEBUG,
)

app.include_router(auth_router)
app.include_router(qr_router)
app.include_router(couple_router)
app.include_router(chat_router)
app.include_router(messages_router)
app.include_router(moments_router)
app.include_router(memories_router)
app.include_router(users_router)
app.include_router(qr_socket_router)
app.include_router(message_reactions.router)

# admin
app.include_router(admin_users.router)
app.include_router(admin_couples.router)


@app.get("/health")
def health_check():
    return {"status": "ok"}

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)