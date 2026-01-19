import { Outlet, NavLink, useNavigate } from "react-router-dom";

import { logoutAdmin } from "../auth/auth.service";
import { jwtDecode } from "jwt-decode";
import "./AdminLayout.css";

export default function AdminLayout() {
  const navigate = useNavigate();  

  const token = localStorage.getItem("admin_access_token");
  let adminName = "Admin";

  if (token) {
    try {
      const payload = jwtDecode(token);
      adminName = payload.email || `Admin #${payload.user_id}`;
    } catch {}
  }

  const handleLogout = async () => {
    try {
      await logoutAdmin();         
    } catch (err) {
      console.error("Logout error:", err);
    } finally {
      navigate("/login", { replace: true }); 
    }
  };

  return (
    <div className="admin-root">
      {/* SIDEBAR */}
      <aside className="admin-sidebar">
        <div className="sidebar-logo">
  <div className="logo-icon">
    <svg viewBox="0 0 24 24">
      <path d="M12 3l8 4v5c0 5-3.5 8-8 9-4.5-1-8-4-8-9V7l8-4z" />
      <path d="M9.5 11.5l2 2 3-3" />
    </svg>
  </div>

  <div className="logo-text-wrap">
    <span className="logo-text">DouDate</span>
    <span className="logo-sub">ADMIN</span>
  </div>
</div>


        <nav className="sidebar-nav">
          <NavLink to="/" end className="nav-item">
            <DashboardIcon />
            <span>Dashboard</span>
          </NavLink>

          <NavLink to="/users" className="nav-item">
            <UsersIcon />
            <span>Users</span>
          </NavLink>

          <NavLink to="/couples" className="nav-item">
            <CouplesIcon />
            <span>Couples</span>
          </NavLink>

          <NavLink to="/messages" className="nav-item">
            <MessagesIcon />
            <span>Messages</span>
          </NavLink>


          {/* <NavLink to="/settings" className="nav-item">
            <SettingsIcon />
            <span>Settings</span>
          </NavLink> */}

          
        </nav>
      </aside>

      {/* MAIN */}
      <div className="admin-main">
        {/* NAVBAR */}
        <header className="admin-navbar">
          <span className="navbar-title">Admin Panel</span>

          <div className="navbar-right">
            <span className="admin-name">{adminName}</span>
            <button className="logout-btn" onClick={handleLogout}>
                  Logout
            </button>

          </div>
        </header>

        {/* CONTENT */}
        <main className="admin-content">
          <Outlet />
        </main>
      </div>
    </div>
  );
}

/* ===== ICONS (SVG INLINE – KHÔNG LIB) ===== */

function DashboardIcon() {
  return (
    <svg viewBox="0 0 24 24" className="nav-icon">
      <rect x="3" y="3" width="8" height="8" />
      <rect x="13" y="3" width="8" height="5" />
      <rect x="13" y="10" width="8" height="11" />
      <rect x="3" y="13" width="8" height="8" />
    </svg>
  );
}

function UsersIcon() {
  return (
    <svg viewBox="0 0 24 24" className="nav-icon">
      <circle cx="9" cy="8" r="3" />
      <circle cx="17" cy="8" r="3" />
      <path d="M3 21c0-3 3-5 6-5s6 2 6 5" />
      <path d="M13 21c0-2 2-4 4-4s4 2 4 4" />
    </svg>
  );
}

function SettingsIcon() {
  return (
    <svg viewBox="0 0 24 24" className="nav-icon">
      <circle cx="12" cy="12" r="3" />
      <path d="M19.4 15a7.9 7.9 0 000-6l2-1.5-2-3.5-2.3 1a8 8 0 00-5.2-3L11.5 1h-4L7.1 3a8 8 0 00-5.2 3l-2.3-1-2 3.5 2 1.5a7.9 7.9 0 000 6l-2 1.5 2 3.5 2.3-1a8 8 0 005.2 3l.4 2h4l.4-2a8 8 0 005.2-3l2.3 1 2-3.5-2-1.5z" />
    </svg>
  );
}

function CouplesIcon() {
  return (
    <svg viewBox="0 0 24 24" className="nav-icon">
      <circle cx="7" cy="8" r="3" />
      <circle cx="17" cy="8" r="3" />
      <path d="M2 21c0-3 3-5 5-5s5 2 5 5" />
      <path d="M12 21c0-3 3-5 5-5s5 2 5 5" />
      <path d="M9 13h6" />
    </svg>
  );
}

function MessagesIcon() {
  return (
    <svg viewBox="0 0 24 24" className="nav-icon">
      <path d="M21 15a4 4 0 01-4 4H7l-4 3V7a4 4 0 014-4h10a4 4 0 014 4z" />
      <path d="M8 9h8" />
      <path d="M8 13h5" />
    </svg>
  );
}


