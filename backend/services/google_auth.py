from firebase_admin import auth as firebase_auth
from firebase_admin.exceptions import FirebaseError


def verify_firebase_id_token(id_token: str) -> dict:
    """
    Verify Firebase ID Token và trả payload user
    """
    try:
        decoded_token = firebase_auth.verify_id_token(id_token)
        return decoded_token
    except FirebaseError:
        raise ValueError("Invalid Firebase ID Token")
