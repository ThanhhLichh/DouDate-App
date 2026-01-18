import { Routes, Route } from "react-router-dom";
import Login from "../pages/Login";
import Dashboard from "../pages/Dashboard";
import Users from "../pages/Users";
import AdminLayout from "../layout/AdminLayout";
import AdminGuard from "../auth/AdminGuard";
import Couples from "../pages/Couples";

export default function AppRoutes() {
  return (
    <Routes>
      {/* LOGIN – KHÔNG LAYOUT */}
      <Route path="/login" element={<Login />} />

      {/* ADMIN LAYOUT */}
      <Route
        path="/"
        element={
          <AdminGuard>
            <AdminLayout />
          </AdminGuard>
        }
      >
        {/* 👇 CÁC PAGE CON Ở ĐÂY */}
        <Route index element={<Dashboard />} />
        <Route path="users" element={<Users />} />
        <Route path="couples" element={<Couples />} />
        {/* sau này thêm settings, reports... */}
      </Route>
    </Routes>
  );
}
