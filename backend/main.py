from fastapi import FastAPI
from core.config import settings
from routers.auth import router as auth_router
from routers.qr import router as qr_router
from routers.couple import router as couple_router

app = FastAPI(
    title=settings.APP_NAME,
    debug=settings.DEBUG,
)

app.include_router(auth_router)
app.include_router(qr_router)
app.include_router(couple_router)


@app.get("/health")
def health_check():
    return {"status": "ok"}
