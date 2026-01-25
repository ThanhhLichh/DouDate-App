import smtplib
from email.mime.text import MIMEText

from core.config import settings


def send_otp_email(to_email: str, otp: str):
    msg = MIMEText(
        f"Mã OTP đặt lại mật khẩu của bạn là: {otp}\n"
        f"Mã có hiệu lực trong 5 phút.",
        "plain",
        "utf-8",
    )

    msg["Subject"] = "Reset password OTP"
    msg["From"] = settings.MAIL_FROM
    msg["To"] = to_email

    with smtplib.SMTP_SSL(settings.SMTP_HOST, settings.SMTP_PORT) as server:
        server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
        server.send_message(msg)
