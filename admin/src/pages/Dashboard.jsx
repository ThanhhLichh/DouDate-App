import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  PieChart,
  Pie,
  Cell,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { Users, HeartHandshake, UserX } from "lucide-react";
import { getDashboardData } from "../api/admin.dashboard";
import "./Dashboard.css";

export default function Dashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();


  useEffect(() => {
    load();
  }, []);

  async function load() {
    try {
      const res = await getDashboardData();
      setData(res);
    } finally {
      setLoading(false);
    }
  }

  if (loading) return <div>Loading dashboard...</div>;

  const { stats, messages_by_day, top_couples } = data;

  const pieData = [
    { name: "Active", value: stats.active_couples },
    { name: "Ended", value: stats.ended_couples },
  ];

  const PIE_COLORS = ["#22c55e", "#ef4444"];

  return (
    <div className="dashboard-page">
      {/* ===== STATS ===== */}
              <div className="stats-grid">
          <StatCard
            title="Total Users"
            value={stats.total_users}
            icon={<Users size={26} />}
            color="blue"
            actionLabel="View Users"
            onAction={() => navigate("/users")}
          />

          <StatCard
            title="Total Couples"
            value={stats.total_couples}
            icon={<HeartHandshake size={26} />}
            color="pink"
            actionLabel="View Couples"
            onAction={() => navigate("/couples")}
          />

          <StatCard
            title="Single Users"
            value={stats.single_users}
            icon={<UserX size={26} />}
            color="orange"
          />
        </div>


      {/* ===== CHARTS ===== */}
      <div className="charts-grid">
        {/* Pie */}
        <div className="chart-box">
          <h3>Couples Status</h3>
          <ResponsiveContainer width="100%" height={260}>
            <PieChart>
              <Pie
                data={pieData}
                dataKey="value"
                nameKey="name"
                outerRadius={90}
                label
              >
                {pieData.map((_, i) => (
                  <Cell key={i} fill={PIE_COLORS[i]} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </div>

        {/* Bar */}
        <div className="chart-box">
          <h3>Messages (Last 7 Days)</h3>
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={messages_by_day}>
              <XAxis dataKey="day" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="total" fill="#3b82f6" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* ===== TOP COUPLES ===== */}
      <div className="table-box">
        <h3>Top Couples by Messages</h3>
        <table className="dashboard-table">
          <thead>
            <tr>
              <th>Couple ID</th>
              <th>Total Messages</th>
            </tr>
          </thead>
          <tbody>
            {top_couples.map((c) => (
              <tr key={c.couple_id}>
                <td>#{c.couple_id}</td>
                <td>{c.total_messages}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function StatCard({
  title,
  value,
  icon,
  color,
  actionLabel,
  onAction,
}) {
  return (
    <div className={`stat-card stat-${color}`}>
      <div className="stat-header">
        <div className="stat-icon">{icon}</div>
        <span className="stat-title">{title}</span>
      </div>

      <div className="stat-value">{value}</div>

      {actionLabel && (
        <button className="stat-action" onClick={onAction}>
          {actionLabel} →
        </button>
      )}
    </div>
  );
}


