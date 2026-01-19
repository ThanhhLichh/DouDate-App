import axios from "./axios";

export async function getDashboardData() {
  const res = await axios.get("/admin/dashboard");
  return res.data;
}
