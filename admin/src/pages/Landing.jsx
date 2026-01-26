import "./Landing.css";
import {
  SiFlutter,
  SiFastapi,
  SiMysql,
  SiFirebase,
  SiCloudinary,
  SiReact
} from "react-icons/si";

import {
  FiMessageCircle,
  FiImage,
  FiBell
} from "react-icons/fi";

import { MdQrCode } from "react-icons/md";


export default function Landing() {
  return (
    <div className="landing">

      {/* ===== HEADER ===== */}
      <header className="landing-header">
        <div className="header-left">
          <img src="/assets/logo.png" alt="DuoDate" className="logo-img" />
          <span className="logo-text">DuoDate</span>
        </div>

        <nav className="header-nav">
          <a href="#features">Tính năng</a>
          <a href="#preview">Giao diện</a>
          <a href="#tech">Công nghệ</a>
          <a href="#team">Nhóm</a>
        </nav>

        <a href="/login" className="btn primary small">
          Tải ứng dụng
        </a>
      </header>

      {/* ===== HERO ===== */}
      <section className="hero">
          {/* Hearts background */}
        <div className="hearts left">
            <span>❤️</span>
            <span>💗</span>
            <span>💖</span>
        </div>

        <div className="hearts right">
            <span>💖</span>
            <span>💗</span>
            <span>❤️</span>
        </div>
        <div className="hero-content">
          <h1>
            Kết nối yêu thương <br />
            <span>Lưu giữ kỷ niệm</span>
          </h1>

          <p>
            Ứng dụng dành riêng cho các cặp đôi – chat riêng tư,
            lưu giữ khoảnh khắc và đồng hành cùng nhau mỗi ngày.
          </p>

          <div className="hero-actions">
            <a href="/login" className="btn primary">Bắt đầu ngay</a>
            {/* <a href="/admin" className="btn ghost">Admin Demo</a> */}
          </div>
        </div>
      </section>

      {/* ===== FEATURES ===== */}
      <section id="features" className="features">
  <h2>Tính năng nổi bật</h2>

  <div className="features-grid">
   <FeatureItem
  icon={<MdQrCode />}
  color="pink"
  title="Kết nối QR"
>

      Ghép đôi nhanh chóng, an toàn chỉ trong vài giây.
    </FeatureItem>

    <FeatureItem
      icon={<FiMessageCircle />}
      color="purple"
      title="Chat realtime"
    >
      Trò chuyện riêng tư, mượt mà theo thời gian thực.
    </FeatureItem>

    <FeatureItem
      icon={<FiImage />}
      color="orange"
      title="Kho kỷ niệm"
    >
      Lưu giữ ảnh và khoảnh khắc đáng nhớ của hai người.
    </FeatureItem>

    <FeatureItem
      icon={<FiBell />}
      color="blue"
      title="Thông báo thông minh"
    >
      Không bỏ lỡ bất kỳ cột mốc quan trọng nào.
    </FeatureItem>
  </div>
</section>


      {/* ===== PREVIEW ===== */}
      <section id="preview" className="preview">
        <h2>Giao diện ứng dụng</h2>

        <div className="preview-grid">
          <img src="/assets/screen1.png" alt="" />
          <img src="/assets/screen2.png" alt="" />
          <img src="/assets/screen3.png" alt="" />
        </div>
      </section>

      {/* ===== TECH ===== */}
      <section id="tech" className="tech">
        <h2>Công nghệ sử dụng</h2>

        <div className="tech-grid">
          <TechItem icon={<SiFlutter />} name="Flutter" />
          <TechItem icon={<SiFastapi />} name="FastAPI" />
          <TechItem icon={<SiMysql />} name="MySQL" />
          <TechItem icon={<SiFirebase />} name="Firebase" />
          <TechItem icon={<SiCloudinary />} name="Cloudinary" />
          <TechItem icon={<SiReact />} name="React + Vite" />
        </div>
      </section>

      {/* ===== TEAM ===== */}
      <section id="team" className="team">
        <h2>Thông tin nhóm</h2>
        <p><strong>Tên đề tài:</strong> DuoDate</p>
        <p><strong>Nhóm / Thành viên:</strong>Nhóm 2</p>
        {/* <p><strong>Môn học / Giảng viên:</strong> …</p> */}
      </section>

      <footer className="landing-footer">
        © 2026 DuoDate. All rights reserved.
      </footer>
    </div>
  );
}

function FeatureItem({ icon, title, children, color }) {
  return (
    <div className="feature-item">
      <div className={`feature-icon ${color}`}>
        {icon}
      </div>
      <h3>{title}</h3>
      <p>{children}</p>
    </div>
  );
}


function TechItem({ icon, name }) {
  return (
    <div className="tech-item">
      <div className="tech-icon">{icon}</div>
      <span>{name}</span>
    </div>
  );
}
