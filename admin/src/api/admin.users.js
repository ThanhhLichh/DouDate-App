import axios from "./axios";

// GET /admin/users
export async function getUsers() {
  const res = await axios.get("/admin/users");
  return res.data;
}

// PATCH /admin/users/{id}/status
export async function updateUserStatus(userId, isActive) {
  const res = await axios.patch(`/admin/users/${userId}/status`, {
    is_active: isActive,
  });
  return res.data;
}
