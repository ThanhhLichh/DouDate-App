<div align="center">

<img src="https://dou-date-app.vercel.app/assets/logo.png" alt="DuoDate Logo" width="96" />

# DuoDate 



<p>
  <img src="https://img.shields.io/badge/Flutter-Mobile-blue" />
  <img src="https://img.shields.io/badge/FastAPI-Backend-success" />
  <img src="https://img.shields.io/badge/MySQL-Database-orange" />
  <img src="https://img.shields.io/badge/React-Admin%20Web-61dafb" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%26%20FCM-yellow" />
</p>

</div>

DuoDate là ứng dụng di động hỗ trợ các cặp đôi kết nối, nhắn tin thời gian thực và lưu giữ những kỷ niệm chung.  
Hệ thống được xây dựng theo mô hình client–server, tích hợp các công nghệ hiện đại nhằm đảm bảo tính bảo mật, hiệu năng và khả năng mở rộng.


---

## 1. Giới thiệu

DuoDate được phát triển như một giải pháp hỗ trợ giao tiếp riêng tư giữa các cặp đôi.  
Ứng dụng không chỉ cung cấp chức năng nhắn tin thời gian thực mà còn cho phép lưu giữ các khoảnh khắc đáng nhớ thông qua chức năng Memories và gửi thông báo đẩy khi người dùng không mở ứng dụng.

### Landing Page:

<p align="center">
  <img src="https://dou-date-app.vercel.app/assets/Screenshot%202026-01-26%20193033.png" alt="Landing Page Preview" />
</p>


## 2. Tính năng chính

- Đăng ký, đăng nhập tài khoản (Email / Google)
- Quên mật khẩu bằng mã OTP
- Kết nối cặp đôi thông qua mã QR
- Nhắn tin thời gian thực (WebSocket)
- Hiển thị trạng thái online/offline
- Đánh dấu tin nhắn đã đọc và phản hồi cảm xúc
- Gửi thông báo đẩy khi có tin nhắn mới
- Quản lý kỷ niệm (Memories): tạo, xem, chỉnh sửa, xóa
- Hệ thống quản trị (Admin Web)

---

## 3.Kiến trúc hệ thống

Hệ thống được xây dựng theo mô hình **Client–Server** với các thành phần chính như sau:

| Thành phần | Công nghệ | Mô tả |
|---------|----------|------|
| 📱 Mobile App | Flutter (Dart) | Ứng dụng di động cho người dùng cuối |
| 🖥️ Backend Server | FastAPI (Python) | Xử lý nghiệp vụ, cung cấp REST API & WebSocket |
| 🗄️ Database | MySQL (Aiven Cloud) | Lưu trữ dữ liệu người dùng và tin nhắn |
| ☁️ Cloud Storage | Cloudinary | Lưu trữ hình ảnh và media |
| 🔐 Authentication | Firebase Authentication | Đăng nhập Google |
| 🔔 Push Notification | Firebase Cloud Messaging | Gửi thông báo đẩy |
| 🛠️ Admin Web | React + Vite | Quản trị và quản lý hệ thống |

📡 **Giao tiếp hệ thống**:
- Mobile App và Admin Web giao tiếp với Backend thông qua **REST API** và **WebSocket**
- Firebase được sử dụng cho:
  - Xác thực đăng nhập Google
  - Gửi thông báo đẩy thời gian thực

---

## 4. Công nghệ sử dụng

### Frontend (Mobile App)
<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
</p>

### Backend
<p>
  <img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" />
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/SQLAlchemy-D71F00?style=for-the-badge&logo=sqlalchemy&logoColor=white" />
  <img src="https://img.shields.io/badge/JWT-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white" />
  <img src="https://img.shields.io/badge/WebSocket-4F4F4F?style=for-the-badge&logo=socket.io&logoColor=white" />
</p>

### Database & Cloud
<p>
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/Aiven-FF3D00?style=for-the-badge&logo=aiven&logoColor=white" />
  <img src="https://img.shields.io/badge/Cloudinary-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white" />
</p>

### Admin Web
<p>
  <img src="https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB" />
  <img src="https://img.shields.io/badge/Vite-646CFF?style=for-the-badge&logo=vite&logoColor=white" />
</p>



## 5. Cài đặt và chạy dự án

### Backend

**Cấu trúc thư mục:**
```bash
backend/
├── core/                 # Core config, database, security, utils
├── firebase/             # Firebase config & services (Auth, FCM)
├── models/               # SQLAlchemy models
├── routers/              # API routers (FastAPI endpoints)
├── schemas/              # Pydantic schemas (request / response)
├── services/             # Business logic layer
├── venv/                 # Python virtual environment
├── .env                  # Environment variables
├── main.py               # FastAPI entry point
├── mysql_schema.sql      # Database schema
└── requirements.txt      # Python dependencies
```
**Cách run:**
```bash
# Clone repository và checkout nhánh backend-dev
git clone -b backend-dev https://github.com/ThanhhLichh/DouDate-App.git

cd DouDate-App/backend

# Tạo virtual environment
python -m venv venv

# Kích hoạt virtual environment
# Linux / macOS
source venv/bin/activate

# Windows
venv\Scripts\activate

# Cài đặt dependencies
pip install -r requirements.txt

# Chạy server
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

Swagger UI: http://localhost:8000/docs
```
### Frontend

**Cấu trúc thư mục:**
```bash
mobile/
├── android/        # Android native config
├── ios/            # iOS native config
├── assets/         # Hình ảnh, icons, fonts
├── lib/
│   ├── core/       # Core modules (constants, services, utils)
│   ├── features/   # Các feature theo domain
│   ├── routes/     # Điều hướng ứng dụng
│   └── main.dart   # Entry point
└──pubspec.yaml
```
**Cách run:**

```bash
# Clone repository
git clone https://github.com/ThanhhLichh/DouDate-App.git

cd DouDate-App/mobile

# Kiểm tra Flutter SDK
flutter doctor

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

## 6. Screenshot Demo

<p align="center">
  <img src="https://dou-date-app.vercel.app/assets/screen1.png" alt="Login Screen" width="250" />
  <img src="https://dou-date-app.vercel.app/assets/screen2.png" alt="Chat Screen" width="250" />
  <img src="https://dou-date-app.vercel.app/assets/screen3.png" alt="Home Screen" width="250" />
</p>


