import { useEffect, useState } from "react";
import { Card } from "components/ui";
import {
  BuildingLibraryIcon,
  BanknotesIcon,
  CalendarDaysIcon,
  RectangleStackIcon,
  ReceiptPercentIcon,
  ArrowTrendingUpIcon,
} from "@heroicons/react/24/outline";
import { querySQL, getStats } from "utils/apiService";

// One round-trip for the headline numbers. Yield/fee use typeof()='real' to
// drop the date-strings that pollute some yield columns, plus a plausible range.
const KPI_SQL = `
  SELECT
    (SELECT COUNT(*) FROM "Gemel"  WHERE REPORT_PERIOD=(SELECT MAX(REPORT_PERIOD) FROM "Gemel"))  AS gemel_funds,
    (SELECT COUNT(*) FROM "Pensia" WHERE REPORT_PERIOD=(SELECT MAX(REPORT_PERIOD) FROM "Pensia")) AS pensia_funds,
    CAST((SELECT MAX(REPORT_PERIOD) FROM "Gemel") AS INTEGER) AS period,
      (SELECT COALESCE(SUM(TOTAL_ASSETS),0) FROM "Gemel"  WHERE REPORT_PERIOD=(SELECT MAX(REPORT_PERIOD) FROM "Gemel"))
    + (SELECT COALESCE(SUM(TOTAL_ASSETS),0) FROM "Pensia" WHERE REPORT_PERIOD=(SELECT MAX(REPORT_PERIOD) FROM "Pensia")) AS total_assets,
    (SELECT ROUND(AVG(AVG_ANNUAL_MANAGEMENT_FEE),2) FROM "Gemel"
       WHERE REPORT_PERIOD=(SELECT MAX(REPORT_PERIOD) FROM "Gemel")
         AND typeof(AVG_ANNUAL_MANAGEMENT_FEE)='real') AS avg_fee,
    (SELECT ROUND(AVG(AVG_ANNUAL_YIELD_TRAILING_3YRS),2) FROM "Gemel"
       WHERE REPORT_PERIOD=(SELECT MAX(REPORT_PERIOD) FROM "Gemel")
         AND typeof(AVG_ANNUAL_YIELD_TRAILING_3YRS)='real'
         AND AVG_ANNUAL_YIELD_TRAILING_3YRS BETWEEN -50 AND 100) AS avg_yield3
`;

// Asset-holding tables whose row counts sum to "securities tracked".
const ASSET_TABLES = [
  "cash_equivalents", "government_bonds", "commercial_papers", "corporate_bonds",
  "traded_stocks", "etfs", "mutual_funds", "warrants", "options", "futures",
  "structured_products", "nt_government_bonds", "nt_designated_bonds",
  "nt_commercial_papers", "nt_corporate_bonds", "nt_stocks", "nt_warrants",
  "nt_options", "nt_other_derivatives", "nt_structured_products", "guaranteed_return",
  "investment_funds", "loans", "deposits_over_3m", "real_estate", "held_companies",
  "other_assets", "credit_facilities", "investment_commitments",
];

const num = (v) => (v == null ? "—" : Number(v).toLocaleString());
const period = (p) => {
  const s = String(p ?? "");
  return s.length === 6 ? `${s.slice(4, 6)}/${s.slice(0, 4)}` : "—";
};
const ils = (thousands) => {
  if (thousands == null) return "—";
  const bn = Number(thousands) / 1e6; // TOTAL_ASSETS is in thousands ILS
  return bn >= 1 ? `₪${bn.toFixed(1)}B` : `₪${(Number(thousands) / 1e3).toFixed(0)}M`;
};
const pct = (v) => (v == null ? "—" : `${Number(v).toFixed(2)}%`);

function Tile({ Icon, color, label, labelHe, value, sub }) {
  return (
    <Card className="p-4">
      <div className="flex items-center gap-3">
        <div className={`flex size-9 shrink-0 items-center justify-center rounded-lg ${color}`}>
          <Icon className="size-5" />
        </div>
        <div className="min-w-0">
          <div className="flex items-baseline gap-1.5">
            <span className="text-[11px] font-medium text-gray-500 dark:text-dark-300">{label}</span>
            <span dir="rtl" className="text-[10px] text-gray-400 dark:text-dark-400">{labelHe}</span>
          </div>
          <p className="truncate text-lg font-semibold text-gray-800 dark:text-dark-50 tabular-nums">
            {value}
          </p>
          {sub && <p className="truncate text-[11px] text-gray-400 dark:text-dark-300">{sub}</p>}
        </div>
      </div>
    </Card>
  );
}

export default function StatTiles() {
  const [k, setK] = useState(null);
  const [securities, setSecurities] = useState(null);

  useEffect(() => {
    querySQL(KPI_SQL).then((r) => setK(r.data?.[0] || {})).catch(() => setK({}));
    getStats()
      .then((s) => setSecurities(ASSET_TABLES.reduce((a, t) => a + (Number(s[t]) > 0 ? Number(s[t]) : 0), 0)))
      .catch(() => setSecurities(null));
  }, []);

  const tiles = [
    {
      Icon: BuildingLibraryIcon, color: "bg-primary-100 text-primary-600 dark:bg-primary-500/15 dark:text-primary-400",
      label: "Funds", labelHe: "קרנות",
      value: k ? num((k.gemel_funds || 0) + (k.pensia_funds || 0)) : "…",
      sub: k ? `Gemel ${num(k.gemel_funds)} · Pensia ${num(k.pensia_funds)}` : "",
    },
    {
      Icon: BanknotesIcon, color: "bg-emerald-100 text-emerald-600 dark:bg-emerald-500/15 dark:text-emerald-400",
      label: "Total assets", labelHe: "סך נכסים",
      value: k ? ils(k.total_assets) : "…", sub: "AUM, latest period",
    },
    {
      Icon: CalendarDaysIcon, color: "bg-amber-100 text-amber-600 dark:bg-amber-500/15 dark:text-amber-400",
      label: "Reporting period", labelHe: "תקופת דיווח",
      value: k ? period(k.period) : "…", sub: "Latest available",
    },
    {
      Icon: RectangleStackIcon, color: "bg-violet-100 text-violet-600 dark:bg-violet-500/15 dark:text-violet-400",
      label: "Securities", labelHe: "ניירות ערך",
      value: securities == null ? "…" : num(securities), sub: "Across 29 asset tables",
    },
    {
      Icon: ReceiptPercentIcon, color: "bg-sky-100 text-sky-600 dark:bg-sky-500/15 dark:text-sky-400",
      label: "Avg. mgmt fee", labelHe: "דמי ניהול ממוצעים",
      value: k ? pct(k.avg_fee) : "…", sub: "Gemel, latest period",
    },
    {
      Icon: ArrowTrendingUpIcon, color: "bg-rose-100 text-rose-600 dark:bg-rose-500/15 dark:text-rose-400",
      label: "Avg. 3Y yield", labelHe: "תשואה ממוצעת 3ש׳",
      value: k ? pct(k.avg_yield3) : "…", sub: "Outliers filtered",
    },
  ];

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 xl:grid-cols-6">
      {tiles.map((t) => (
        <Tile key={t.label} {...t} />
      ))}
    </div>
  );
}
