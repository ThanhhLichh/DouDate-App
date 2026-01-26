import { Routes, Route } from "react-router-dom";
import Login from "../pages/Login";
import Landing from "../pages/Landing";
import Dashboard from "../pages/Dashboard";
import Users from "../pages/Users";
import AdminLayout from "../layout/AdminLayout";
import AdminGuard from "../auth/AdminGuard";
import Couples from "../pages/Couples";
import Messages from "../pages/Messages";
import Memories from "../pages/Memories";

export default function AppRoutes() {
  return (
    <Routes>

      {/*  LANDING PAGE – PUBLIC */}
      <Route path="/landing" element={<Landing />} />
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
        <Route path="couples/:coupleId/messages" element={<Messages />} />
        <Route path="messages" element={<Messages />} />
        <Route path="memories" element={<Memories />} />

        {/* sau này thêm settings, reports... */}
      </Route>
    </Routes>
  );
}
