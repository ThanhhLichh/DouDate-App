import { useState } from "react";
import { getMemoriesByCouple, deleteMemory } from "../api/admin.memories";
import Pagination from "../components/Pagination";
import "./Memories.css";

export default function Memories() {
  const [coupleId, setCoupleId] = useState("");
  const [memories, setMemories] = useState([]);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [actionLoading, setActionLoading] = useState(null);

  const LIMIT = 10;
  const totalPages = Math.ceil(total / LIMIT);

  async function loadMemories(pageNumber = 1) {
    if (!coupleId) return;

    setLoading(true);
    try {
      const res = await getMemoriesByCouple(coupleId, pageNumber, LIMIT);
      setMemories(res.items);
      setTotal(res.total);
      setPage(pageNumber);
    } catch {
      alert("Không tải được memories");
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete(memoryId) {
    const ok = window.confirm("Xoá memory này?");
    if (!ok) return;

    setActionLoading(memoryId);
    try {
      await deleteMemory(memoryId);
      setMemories((prev) => prev.filter((m) => m.id !== memoryId));
      setTotal((t) => t - 1);
    } catch {
      alert("Xoá memory thất bại");
    } finally {
      setActionLoading(null);
    }
  }

  return (
    <div className="memories-page">
      <h1>Memories</h1>

      {/* INPUT COUPLE ID */}
      <div className="memories-toolbar">
        <input
          type="number"
          placeholder="Enter couple ID..."
          value={coupleId}
          onChange={(e) => setCoupleId(e.target.value)}
        />
        <button onClick={() => loadMemories(1)}>
          Load Memories
        </button>
      </div>

      {loading && <div>Loading...</div>}

      <div className="memories-list">
        {memories.map((m) => (
          <div key={m.id} className="memory-item">
            {m.image_url && (
              <img src={m.image_url} alt="memory" />
            )}

            <div className="memory-content">
              <strong>{m.title || "Memory"}</strong>

              {m.description && <p>{m.description}</p>}

              <span className="memory-time">
                {m.memory_date
                  ? `Memory date: ${m.memory_date}`
                  : new Date(m.created_at).toLocaleString()}
              </span>

              {/* 🔥 DELETE BUTTON */}
              <button
                className="memory-delete-btn"
                disabled={actionLoading === m.id}
                onClick={() => handleDelete(m.id)}
              >
                {actionLoading === m.id ? "..." : "Delete"}
              </button>
            </div>
          </div>
        ))}

        {!loading && memories.length === 0 && (
          <div>No memories</div>
        )}
      </div>

      {/* PAGINATION */}
      <Pagination
        page={page}
        totalPages={totalPages}
        onPageChange={(p) => loadMemories(p)}
      />
    </div>
  );
}
