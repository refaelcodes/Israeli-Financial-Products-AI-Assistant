import useApiData from "hooks/useApiData";
import { querySQL } from "utils/apiService";
import { Card, Badge } from "components/ui";

const SQL = `
  SELECT name, corp, ROUND(assets/1e6, 2) AS aum, fee, y3, ftype
  FROM (
    SELECT FUND_NAME AS name, MANAGING_CORPORATION AS corp, TOTAL_ASSETS AS assets,
           AVG_ANNUAL_MANAGEMENT_FEE AS fee, AVG_ANNUAL_YIELD_TRAILING_3YRS AS y3, 'Gemel' AS ftype
      FROM "Gemel"  WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "Gemel")
    UNION ALL
    SELECT FUND_NAME, MANAGING_CORPORATION, TOTAL_ASSETS,
           AVG_ANNUAL_MANAGEMENT_FEE, AVG_ANNUAL_YIELD_TRAILING_3YRS, 'Pensia'
      FROM "Pensia" WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "Pensia")
  )
  WHERE assets IS NOT NULL
  ORDER BY aum DESC LIMIT 8
`;

// yields/fees are noisy in the raw data — show a number only when it is one.
const pct = (v) => {
  const n = Number(v);
  return Number.isFinite(n) && Math.abs(n) < 1000 ? `${n.toFixed(2)}%` : "—";
};

export default function TopFundsTable() {
  const { data, loading, error } = useApiData(() => querySQL(SQL), []);

  return (
    <Card className="p-4">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-sm font-medium text-gray-800 dark:text-dark-50">
            Top funds by assets
          </h3>
          <p className="mt-0.5 text-[11px] text-gray-400 dark:text-dark-300">
            Gemel + Pensia · latest period
          </p>
        </div>
        <span dir="rtl" className="text-xs text-gray-400 dark:text-dark-300">
          קרנות מובילות לפי היקף נכסים
        </span>
      </div>

      <div className="mt-3 overflow-x-auto">
        {loading ? (
          <p className="py-6 text-center text-xs text-gray-400">Loading…</p>
        ) : error ? (
          <p className="py-6 text-center text-xs text-red-500">⚠ {error}</p>
        ) : (
          <table className="w-full min-w-[560px] text-sm">
            <thead>
              <tr className="border-b border-gray-200 text-left text-[11px] font-medium text-gray-400 dark:border-dark-500 dark:text-dark-300">
                <th className="py-2 pr-3 font-medium">Fund · קרן</th>
                <th className="py-2 pr-3 font-medium">Manager · בית השקעות</th>
                <th className="py-2 pr-3 font-medium">Type</th>
                <th className="py-2 pr-3 text-right font-medium">AUM</th>
                <th className="py-2 pr-3 text-right font-medium">Fee</th>
                <th className="py-2 text-right font-medium">3Y</th>
              </tr>
            </thead>
            <tbody>
              {data.map((r, i) => (
                <tr
                  key={i}
                  className="border-b border-gray-100 last:border-0 dark:border-dark-600"
                >
                  <td className="max-w-[180px] truncate py-2 pr-3 text-gray-800 dark:text-dark-100" dir="auto">
                    {r.name}
                  </td>
                  <td className="max-w-[160px] truncate py-2 pr-3 text-gray-500 dark:text-dark-300" dir="auto">
                    {r.corp}
                  </td>
                  <td className="py-2 pr-3">
                    <Badge variant="soft" color={r.ftype === "Pensia" ? "secondary" : "primary"} className="text-[10px]">
                      {r.ftype}
                    </Badge>
                  </td>
                  <td className="py-2 pr-3 text-right tabular-nums text-gray-800 dark:text-dark-100">
                    ₪{Number(r.aum).toFixed(1)}B
                  </td>
                  <td className="py-2 pr-3 text-right tabular-nums text-gray-500 dark:text-dark-300">
                    {pct(r.fee)}
                  </td>
                  <td className="py-2 text-right tabular-nums text-gray-500 dark:text-dark-300">
                    {pct(r.y3)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </Card>
  );
}
