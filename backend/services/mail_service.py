import os
import requests


def send_otp_email(to_email: str, otp: str):
    api_key = os.getenv("RESEND_API_KEY")

    # DEV fallback (nếu quên set env)
    if not api_key:
        print(f"[OTP DEV] {to_email} -> {otp}")
        return

    response = requests.post(
        "https://api.resend.com/emails",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        json={
            "from": os.getenv("MAIL_FROM", "no-reply@doudate.app"),
            "to": [to_email],
            "subject": "Reset password OTP",
            "html": f"""
                <h3>DouDate</h3>
                <p>Mã OTP đặt lại mật khẩu của bạn là:</p>
                <h2>{otp}</h2>
                <p>Mã có hiệu lực trong 5 phút.</p>
            """,
        },
        timeout=10,
    )

    if response.status_code >= 400:
        print("Resend error:", response.text)
