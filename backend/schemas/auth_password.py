from pydantic import BaseModel, EmailStr


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class VerifyOtpRequest(BaseModel):
    email: EmailStr
    otp: str
    token: str


class ResetPasswordRequest(BaseModel):
    reset_token: str
    new_password: str
