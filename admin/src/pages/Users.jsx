import { useEffect, useState, useMemo } from "react";
import { getUsers, updateUserStatus } from "../api/admin.users";
import "./Users.css";

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(null);

  // 🔍 search + filter state
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all"); // all | active | banned

  useEffect(() => {
    loadUsers();
  }, []);

  async function loadUsers() {
    try {
      const data = await getUsers();
      const sorted = [...data].sort((a, b) => a.id - b.id);
      setUsers(sorted);
    } catch (err) {
      console.error(err);
      alert("Không tải được danh sách user");
    } finally {
      setLoading(false);
    }
  }

  async function toggleUser(user) {
    setActionLoading(user.id);
    try {
      const updated = await updateUserStatus(user.id, !user.is_active);
      setUsers((prev) =>
        prev.map((u) => (u.id === user.id ? updated : u))
      );
    } catch (err) {
      alert("Thao tác thất bại");
    } finally {
      setActionLoading(null);
    }
  }

  // 🔥 FILTER LOGIC (search + status)
  const filteredUsers = useMemo(() => {
    return users.filter((u) => {
      const keyword = search.toLowerCase();

      const matchSearch =
        u.email.toLowerCase().includes(keyword) ||
        (u.full_name || "").toLowerCase().includes(keyword);

      const matchStatus =
        statusFilter === "all" ||
        (statusFilter === "active" && u.is_active) ||
        (statusFilter === "banned" && !u.is_active);

      return matchSearch && matchStatus;
    });
  }, [users, search, statusFilter]);

  if (loading) {
    return <div className="users-loading">Loading users...</div>;
  }

  return (
    <div className="users-page">
      <h1 className="users-title">Users</h1>

      {/* 🔍 SEARCH + FILTER */}
      <div className="users-toolbar">
        <input
          type="text"
          placeholder="Search by email or name..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="users-search"
        />

        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="users-filter"
        >
          <option value="all">All</option>
          <option value="active">Active</option>
          <option value="banned">Banned</option>
        </select>
      </div>

      <div className="users-table-wrap">
        <table className="users-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Email</th>
              <th>Full name</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>

          <tbody>
            {filteredUsers.map((user) => (
              <tr key={user.id}>
                <td>{user.id}</td>
                <td>{user.email}</td>
                <td>{user.full_name || "-"}</td>

                <td>
                  <span
                    className={
                      user.is_active
                        ? "status status-active"
                        : "status status-banned"
                    }
                  >
                    {user.is_active ? "Active" : "Banned"}
                  </span>
                </td>

                <td>
                  <button
                    className={
                      user.is_active
                        ? "action-btn ban"
                        : "action-btn unban"
                    }
                    disabled={actionLoading === user.id}
                    onClick={() => toggleUser(user)}
                  >
                    {actionLoading === user.id
                      ? "..."
                      : user.is_active
                      ? "Ban"
                      : "Unban"}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {filteredUsers.length === 0 && (
          <div className="users-empty">No users found</div>
        )}
      </div>
    </div>
  );
}
