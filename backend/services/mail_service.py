import requests
from core.config import settings



# import smtplib

# from email.mime.text import MIMEText



# from core.config import settings





# def send_otp_email(to_email: str, otp: str):

#     msg = MIMEText(

#         f"Mã OTP đặt lại mật khẩu của bạn là: {otp}\n"

#         f"Mã có hiệu lực trong 5 phút.",

#         "plain",

#         "utf-8",

#     )



#     msg["Subject"] = "Reset password OTP"

#     msg["From"] = settings.MAIL_FROM

#     msg["To"] = to_email



#     with smtplib.SMTP_SSL(settings.SMTP_HOST, settings.SMTP_PORT) as server:

#         server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)

def send_otp_email(to_email: str, otp: str):
    url = "https://api.emailjs.com/api/v1.0/email/send"
    
    payload = {
        "service_id": settings.EMAILJS_SERVICE_ID,
        "template_id": settings.EMAILJS_TEMPLATE_ID,
        "user_id": settings.EMAILJS_PUBLIC_KEY,
        "accessToken": settings.EMAILJS_PRIVATE_KEY, # THÊM DÒNG NÀY ĐỂ FIX LỖI
        "template_params": {
            "email": to_email,
            "passcode": otp,
            "time": "5 phút"
        }
    }

    try:
        # Quan trọng: Phải có header Content-Type
        headers = {'Content-Type': 'application/json'}
        response = requests.post(url, json=payload, headers=headers)
        
        if response.status_code == 200:
            print(f"✅ Gửi OTP thành công tới: {to_email}")
            return True
        else:
            # Nếu vẫn lỗi, nó sẽ in ra chi tiết tại đây
            print(f"❌ Lỗi EmailJS: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Lỗi kết nối: {e}")
        return False