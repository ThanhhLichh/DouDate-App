import os
import json
import tempfile
import firebase_admin
from firebase_admin import credentials

from core.config import settings


def init_firebase():
    if firebase_admin._apps:
        return

    # CASE 1: Railway / Cloud – dùng ENV JSON
    if settings.FIREBASE_CREDENTIALS_JSON:
        cred_dict = json.loads(settings.FIREBASE_CREDENTIALS_JSON)

        with tempfile.NamedTemporaryFile(mode="w+", delete=False) as f:
            json.dump(cred_dict, f)
            cred_path = f.name

        cred = credentials.Certificate(cred_path)

    # CASE 2: Local dev – dùng file path
    elif settings.FIREBASE_CREDENTIALS:
        cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS)

    else:
        raise RuntimeError("Missing Firebase credentials")

    firebase_admin.initialize_app(cred)
