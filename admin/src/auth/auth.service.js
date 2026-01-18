import axios from "../api/axios";
import { jwtDecode } from "jwt-decode";

const ACCESS_KEY = "admin_access_token";
const REFRESH_KEY = "admin_refresh_token";

export async function loginAdmin(email, password) {
  const res = await axios.post("/auth/login", { email, password });

  const { access_token, refresh_token } = res.data;
  const payload = jwtDecode(access_token);

  if (payload.role !== "admin") {
    throw new Error("Tài khoản không có quyền admin");
  }

  localStorage.setItem(ACCESS_KEY, access_token);
  localStorage.setItem(REFRESH_KEY, refresh_token);

  return payload;
}

export async function refreshAdminToken() {
  const refreshToken = localStorage.getItem(REFRESH_KEY);
  if (!refreshToken) throw new Error("No refresh token");

  const res = await axios.post("/auth/refresh", {
    refresh_token: refreshToken,
  });

  localStorage.setItem(ACCESS_KEY, res.data.access_token);
  localStorage.setItem(REFRESH_KEY, res.data.refresh_token);

  return res.data.access_token;
}

export async function logoutAdmin() {
  const refreshToken = localStorage.getItem(REFRESH_KEY);

  if (refreshToken) {
    await axios.post("/auth/logout", { refresh_token: refreshToken });
  }

  localStorage.removeItem(ACCESS_KEY);
  localStorage.removeItem(REFRESH_KEY);
}

export function getAccessToken() {
  return localStorage.getItem(ACCESS_KEY);
}
