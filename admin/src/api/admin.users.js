import axios from "./axios";

// GET /admin/users
export async function getUsers(page = 1, limit = 10) {
  const res = await axios.get("/admin/users", {
    params: { page, limit },
  });
  return res.data; // { items, total, page, limit }
}


// PATCH /admin/users/{id}/status
export async function updateUserStatus(userId, isActive) {
  const res = await axios.patch(`/admin/users/${userId}/status`, {
    is_active: isActive,
  });
  return res.data;
}
