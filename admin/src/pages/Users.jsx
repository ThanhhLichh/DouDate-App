import { useEffect, useState, useMemo } from "react";
import { getUsers, updateUserStatus } from "../api/admin.users";
import Pagination from "../components/Pagination";
import "./Users.css";

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(null);

  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);

  // 🔍 search + filter (trên page hiện tại)
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");

  const LIMIT = 10;
  const totalPages = Math.ceil(total / LIMIT);

  useEffect(() => {
    loadUsers(1);
  }, []);

  async function loadUsers(p = 1) {
    setLoading(true);
    try {
      const res = await getUsers(p, LIMIT);
      setUsers(res.items);
      setTotal(res.total);
      setPage(p);
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
    } catch {
      alert("Thao tác thất bại");
    } finally {
      setActionLoading(null);
    }
  }

  // 🔍 FILTER (chỉ trong page hiện tại – chuẩn admin)
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

      {/* SEARCH + FILTER */}
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

      {/* PAGINATION (DÙNG CHUNG) */}
      <Pagination
        page={page}
        totalPages={totalPages}
        onPageChange={(p) => loadUsers(p)}
      />
    </div>
  );
}
