import os
import firebase_admin
from firebase_admin import credentials

from core.config import settings


def init_firebase():
    if not firebase_admin._apps:
        cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS)
        firebase_admin.initialize_app(cred)
