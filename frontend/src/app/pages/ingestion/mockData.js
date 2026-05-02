export const KANBAN_COLUMNS = [
  { id: "ready", title: "Ready", color: "primary" },
  { id: "waiting", title: "Waiting / Blocked", color: "warning" },
  { id: "in_process", title: "In Process", color: "info" },
  { id: "done", title: "Done", color: "success" },
];

let nextId = 20;
export const getNextId = () => nextId++;

export const initialTasks = [
  // Ready
  { id: 1, column: "ready", title: "Menora Q4 2025 Holdings", source: "Menora Mivtachim", fileType: "CSV", records: 12500, priority: "high", createdAt: "2026-02-14T08:30:00", assignee: "Sarah K." },
  { id: 2, column: "ready", title: "Migdal Monthly NAV Report", source: "Migdal Insurance", fileType: "Excel", records: 340, priority: "medium", createdAt: "2026-02-14T09:15:00", assignee: "David L." },
  { id: 3, column: "ready", title: "TASE Daily Prices Feed", source: "TASE", fileType: "API", records: 890, priority: "high", createdAt: "2026-02-15T06:00:00", assignee: "Auto" },

  // Waiting / Blocked
  { id: 4, column: "waiting", title: "Phoenix Gemel Positions", source: "The Phoenix", fileType: "XML", records: 5200, priority: "medium", createdAt: "2026-02-13T14:00:00", assignee: "Rachel M.", blockedReason: "Missing mapping for 3 new securities" },
  { id: 5, column: "waiting", title: "Clal Corp Bond Updates", source: "Clal Insurance", fileType: "CSV", records: 1800, priority: "low", createdAt: "2026-02-12T11:00:00", assignee: "Yossi B.", blockedReason: "Awaiting clarification on FX rates" },

  // In Process
  { id: 6, column: "in_process", title: "Harel Pensia Full Recon", source: "Harel Insurance", fileType: "Excel", records: 8900, priority: "high", createdAt: "2026-02-14T10:00:00", assignee: "David L.", progress: 65 },
  { id: 7, column: "in_process", title: "Bloomberg Market Data", source: "Bloomberg", fileType: "API", records: 45000, priority: "high", createdAt: "2026-02-15T07:00:00", assignee: "Auto", progress: 30 },
  { id: 8, column: "in_process", title: "Altshuler ETF Holdings", source: "Altshuler Shaham", fileType: "CSV", records: 3200, priority: "medium", createdAt: "2026-02-14T16:00:00", assignee: "Sarah K.", progress: 85 },

  // Done
  { id: 9, column: "done", title: "Psagot Daily Valuations", source: "Psagot Investment", fileType: "API", records: 2100, priority: "medium", createdAt: "2026-02-14T06:00:00", assignee: "Auto", completedAt: "2026-02-14T06:12:00" },
  { id: 10, column: "done", title: "TASE Index Compositions", source: "TASE", fileType: "CSV", records: 450, priority: "low", createdAt: "2026-02-13T08:00:00", assignee: "Rachel M.", completedAt: "2026-02-13T14:30:00" },
  { id: 11, column: "done", title: "Menora Q3 Reconciliation", source: "Menora Mivtachim", fileType: "Excel", records: 11200, priority: "high", createdAt: "2026-02-10T09:00:00", assignee: "David L.", completedAt: "2026-02-12T17:00:00" },
  { id: 12, column: "done", title: "Risk Factor Updates", source: "Internal", fileType: "API", records: 680, priority: "medium", createdAt: "2026-02-13T15:00:00", assignee: "Auto", completedAt: "2026-02-13T15:05:00" },
];
