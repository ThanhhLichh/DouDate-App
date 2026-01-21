import { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import {
  getMessagesByCouple,
  deleteMessage,
} from "../api/admin.messages";
import Pagination from "../components/Pagination";
import "./Messages.css";

export default function Messages() {
  const [searchParams] = useSearchParams();
  const initialCoupleId = searchParams.get("coupleId") || "";

  const [coupleId, setCoupleId] = useState(initialCoupleId);
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);
  const [actionLoading, setActionLoading] = useState(null);

  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);

  const LIMIT = 10;
  const totalPages = Math.ceil(total / LIMIT);

  useEffect(() => {
    if (initialCoupleId) {
      loadMessages(initialCoupleId, 1);
    }
  }, [initialCoupleId]);

  async function loadMessages(id, pageNumber = 1) {
    if (!id) return;

    setLoading(true);
    try {
      const res = await getMessagesByCouple(id, pageNumber, LIMIT);
      setMessages(res.items);
      setTotal(res.total);
      setPage(res.page);
    } catch {
      alert("Không tải được tin nhắn");
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete(messageId) {
    const ok = window.confirm("Xoá tin nhắn này?");
    if (!ok) return;

    setActionLoading(messageId);
    try {
      await deleteMessage(messageId);
      setMessages((prev) => prev.filter((m) => m.id !== messageId));
      setTotal((t) => t - 1);
    } catch {
      alert("Xoá thất bại");
    } finally {
      setActionLoading(null);
    }
  }

  return (
    <div className="messages-page">
      <h1>Messages</h1>

      {/* INPUT COUPLE ID */}
      <div className="messages-toolbar">
        <input
          type="number"
          placeholder="Enter couple ID..."
          value={coupleId}
          onChange={(e) => setCoupleId(e.target.value)}
        />
        <button onClick={() => loadMessages(coupleId, 1)}>
          Load Messages
        </button>
      </div>

      {loading && <div>Loading...</div>}

      <div className="messages-grid">
        {messages.map((m) => (
          <div key={m.id} className="message-item">
            <div className="message-meta">
              <span>Sender #{m.sender_id}</span>
              <span>{new Date(m.created_at).toLocaleString()}</span>
            </div>

            <div className="message-content">
              {m.type === "text" && <p>{m.content}</p>}
              {m.type === "image" && (
                <img src={m.img_url} alt="message" />
              )}
            </div>

            <button
              className="delete-btn"
              disabled={actionLoading === m.id}
              onClick={() => handleDelete(m.id)}
            >
              {actionLoading === m.id ? "..." : "Delete"}
            </button>
          </div>
        ))}

        {!loading && messages.length === 0 && (
          <div>No messages</div>
        )}
      </div>

      <Pagination
        page={page}
        totalPages={totalPages}
        onPageChange={(p) => loadMessages(coupleId, p)}
      />
    </div>
  );
}
