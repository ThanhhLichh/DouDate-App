import { useState } from "react";
import { getMemoriesByCouple } from "../api/admin.memories";
import Pagination from "../components/Pagination";
import "./Memories.css";

export default function Memories() {
  const [coupleId, setCoupleId] = useState("");
  const [memories, setMemories] = useState([]);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);

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
            </div>
          </div>
        ))}

        {!loading && memories.length === 0 && (
          <div>No memories</div>
        )}
      </div>

      {/* PAGINATION (DÙNG CHUNG) */}
      <Pagination
        page={page}
        totalPages={totalPages}
        onPageChange={(p) => loadMemories(p)}
      />
    </div>
  );
}
