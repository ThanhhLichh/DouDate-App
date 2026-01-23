from pydantic import BaseModel

class SaveFCMTokenRequest(BaseModel):
    fcm_token: str
