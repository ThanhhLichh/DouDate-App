import { useNavigate } from "react-router-dom";
import { useEffect, useState, useMemo } from "react";
import { getCouples, breakCouple } from "../api/admin.couples";
import Pagination from "../components/Pagination";
import "./Couples.css";

export default function Couples() {
  const [couples, setCouples] = useState([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(null);

  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);

  const navigate = useNavigate();

  // 🔍 filter (trên page hiện tại)
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all"); // all | active | ended

  const LIMIT = 10;
  const totalPages = Math.ceil(total / LIMIT);

  useEffect(() => {
    loadCouples(1);
  }, []);

  async function loadCouples(p = 1) {
    setLoading(true);
    try {
      const res = await getCouples(p, LIMIT);
      setCouples(res.items);
      setTotal(res.total);
      setPage(p);
    } catch (err) {
      console.error(err);
      alert("Không tải được danh sách couple");
    } finally {
      setLoading(false);
    }
  }

  async function handleBreak(couple) {
    const ok = window.confirm(
      `Bạn chắc chắn muốn break couple #${couple.id}?`
    );
    if (!ok) return;

    setActionLoading(couple.id);
    try {
      const updated = await breakCouple(couple.id);
      setCouples((prev) =>
        prev.map((c) => (c.id === couple.id ? updated : c))
      );
    } catch {
      alert("Break couple thất bại");
    } finally {
      setActionLoading(null);
    }
  }

  // 🔥 FILTER LOGIC (trên page hiện tại)
  const filteredCouples = useMemo(() => {
    return couples.filter((c) => {
      const matchSearch =
        search === "" || String(c.id).includes(search);

      const isEnded = Boolean(c.end_date);
      const matchStatus =
        statusFilter === "all" ||
        (statusFilter === "active" && !isEnded) ||
        (statusFilter === "ended" && isEnded);

      return matchSearch && matchStatus;
    });
  }, [couples, search, statusFilter]);

  if (loading) {
    return <div className="couples-loading">Loading couples...</div>;
  }

  return (
    <div className="couples-page">
      <h1 className="couples-title">Couples</h1>

      {/* SEARCH + FILTER */}
      <div className="couples-toolbar">
        <input
          type="text"
          placeholder="Search by couple id..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="couples-search"
        />

        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="couples-filter"
        >
          <option value="all">All</option>
          <option value="active">Active</option>
          <option value="ended">Ended</option>
        </select>
      </div>

      <div className="couples-table-wrap">
        <table className="couples-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>User 1</th>
              <th>User 2</th>
              <th>Nickname 1</th>
              <th>Nickname 2</th>
              <th>Start date</th>
              <th>End date</th>
              <th>Action</th>
            </tr>
          </thead>

          <tbody>
            {filteredCouples.map((c) => (
              <tr key={c.id}>
                <td>{c.id}</td>
                <td>{c.user1_id}</td>
                <td>{c.user2_id}</td>
                <td>{c.nickname_1 || "-"}</td>
                <td>{c.nickname_2 || "-"}</td>
                <td>{c.start_date}</td>
                <td>{c.end_date || "-"}</td>
                <td>
                  <div className="action-group">
                    <button
                      className="action-btn view"
                      onClick={() =>
                        navigate(`/messages?coupleId=${c.id}`)
                      }
                    >
                      View Messages
                    </button>

                    {c.end_date ? (
                      <span className="status status-ended">
                        Ended
                      </span>
                    ) : (
                      <button
                        className="action-btn break"
                        disabled={actionLoading === c.id}
                        onClick={() => handleBreak(c)}
                      >
                        {actionLoading === c.id ? "..." : "Break"}
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {filteredCouples.length === 0 && (
          <div className="couples-empty">No couples found</div>
        )}
      </div>

      {/* PAGINATION (DÙNG CHUNG) */}
      <Pagination
        page={page}
        totalPages={totalPages}
        onPageChange={(p) => loadCouples(p)}
      />
    </div>
  );
}
