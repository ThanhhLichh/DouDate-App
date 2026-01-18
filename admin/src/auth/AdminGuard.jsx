import { Navigate } from "react-router-dom";
import { jwtDecode } from "jwt-decode";
import { getAccessToken } from "./auth.service";

export default function AdminGuard({ children }) {
  const token = getAccessToken();
  if (!token) return <Navigate to="/login" />;

  try {
    const { role, exp } = jwtDecode(token);
    if (role !== "admin") return <Navigate to="/login" />;
    if (Date.now() / 1000 > exp) return <Navigate to="/login" />;
  } catch {
    return <Navigate to="/login" />;
  }

  return children;
}
