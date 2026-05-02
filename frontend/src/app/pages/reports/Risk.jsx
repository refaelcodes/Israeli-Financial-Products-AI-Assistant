import { Card } from "components/ui";
import { Badge } from "components/ui";

const riskMetrics = [
  { metric: "Portfolio VaR (95%)", value: "₪12.5M", status: "normal", threshold: "₪15M", trend: "down" },
  { metric: "Portfolio VaR (99%)", value: "₪18.2M", status: "warning", threshold: "₪20M", trend: "up" },
  { metric: "Tracking Error", value: "2.1%", status: "normal", threshold: "3.0%", trend: "stable" },
  { metric: "Sharpe Ratio", value: "1.45", status: "normal", threshold: "> 1.0", trend: "up" },
  { metric: "Max Drawdown", value: "-4.2%", status: "normal", threshold: "-10%", trend: "stable" },
  { metric: "Beta to TA-125", value: "0.82", status: "normal", threshold: "0.5 - 1.2", trend: "stable" },
  { metric: "Duration (Fixed Income)", value: "4.5Y", status: "warning", threshold: "< 4.0Y", trend: "up" },
  { metric: "Credit Spread Duration", value: "3.2Y", status: "normal", threshold: "< 5.0Y", trend: "stable" },
];

const concentrationRisks = [
  { name: "Top 10 Holdings", weight: 32.5, limit: 40, status: "ok" },
  { name: "Single Issuer Max", weight: 6.6, limit: 10, status: "ok" },
  { name: "Sector - Financials", weight: 22.1, limit: 25, status: "warning" },
  { name: "Sector - Technology", weight: 18.5, limit: 25, status: "ok" },
  { name: "Country - Israel", weight: 48.2, limit: 60, status: "ok" },
  { name: "Country - US", weight: 35.8, limit: 40, status: "warning" },
  { name: "Currency - USD", weight: 38.5, limit: 50, status: "ok" },
  { name: "Currency - ILS", weight: 45.2, limit: 60, status: "ok" },
];

export default function Risk() {
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <Card className="p-5">
          <h3 className="text-base font-semibold text-gray-800 dark:text-dark-50 mb-4">
            Risk Metrics
          </h3>
          <div className="space-y-3">
            {riskMetrics.map((m) => (
              <div key={m.metric} className="flex items-center justify-between py-1.5 border-b border-gray-100 dark:border-dark-600 last:border-0">
                <div>
                  <p className="text-sm text-gray-700 dark:text-dark-100">{m.metric}</p>
                  <p className="text-xs text-gray-400 dark:text-dark-400">Limit: {m.threshold}</p>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-sm font-semibold text-gray-800 dark:text-dark-50">{m.value}</span>
                  <Badge
                    variant="soft"
                    color={m.status === "normal" ? "success" : m.status === "warning" ? "warning" : "error"}
                    className="text-[10px] px-1.5"
                  >
                    {m.status}
                  </Badge>
                </div>
              </div>
            ))}
          </div>
        </Card>

        <Card className="p-5">
          <h3 className="text-base font-semibold text-gray-800 dark:text-dark-50 mb-4">
            Concentration Limits
          </h3>
          <div className="space-y-3">
            {concentrationRisks.map((c) => (
              <div key={c.name} className="space-y-1">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-700 dark:text-dark-100">{c.name}</span>
                  <div className="flex items-center gap-2">
                    <span className="font-medium text-gray-800 dark:text-dark-50">{c.weight}%</span>
                    <span className="text-xs text-gray-400 dark:text-dark-400">/ {c.limit}%</span>
                  </div>
                </div>
                <div className="h-2 w-full rounded-full bg-gray-100 dark:bg-dark-500">
                  <div
                    className={`h-full rounded-full transition-all ${
                      c.weight / c.limit > 0.9
                        ? "bg-red-500"
                        : c.weight / c.limit > 0.75
                        ? "bg-amber-500"
                        : "bg-emerald-500"
                    }`}
                    style={{ width: `${Math.min((c.weight / c.limit) * 100, 100)}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>
    </div>
  );
}
