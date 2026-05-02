import { Card } from "components/ui";
import { Badge } from "components/ui";

const quarterlyData = [
  { quarter: "Q4 2025", totalAUM: "₪245.2B", netFlows: "+₪3.1B", returnPct: 3.2, topPerformer: "Altshuler Shaham", topReturn: 4.1, exceptions: 12, resolved: 10 },
  { quarter: "Q3 2025", totalAUM: "₪238.8B", netFlows: "+₪2.8B", returnPct: 2.8, topPerformer: "Harel Insurance", topReturn: 3.5, exceptions: 8, resolved: 8 },
  { quarter: "Q2 2025", totalAUM: "₪232.1B", netFlows: "+₪1.9B", returnPct: 1.5, topPerformer: "Menora Mivtachim", topReturn: 2.1, exceptions: 15, resolved: 14 },
  { quarter: "Q1 2025", totalAUM: "₪228.4B", netFlows: "-₪0.5B", returnPct: -0.8, topPerformer: "Psagot Investment", topReturn: 0.2, exceptions: 22, resolved: 20 },
];

export default function Quarterly() {
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        {quarterlyData.map((q) => (
          <Card key={q.quarter} className="p-5">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-800 dark:text-dark-50">
                {q.quarter}
              </h3>
              <Badge
                variant="soft"
                color={q.returnPct >= 0 ? "success" : "error"}
                className="text-sm"
              >
                {q.returnPct >= 0 ? "+" : ""}{q.returnPct}%
              </Badge>
            </div>

            <div className="grid grid-cols-2 gap-3 text-sm">
              <div>
                <p className="text-gray-500 dark:text-dark-300">Total AUM</p>
                <p className="font-medium text-gray-800 dark:text-dark-50">{q.totalAUM}</p>
              </div>
              <div>
                <p className="text-gray-500 dark:text-dark-300">Net Flows</p>
                <p className="font-medium text-gray-800 dark:text-dark-50">{q.netFlows}</p>
              </div>
              <div>
                <p className="text-gray-500 dark:text-dark-300">Top Performer</p>
                <p className="font-medium text-gray-800 dark:text-dark-50">{q.topPerformer}</p>
              </div>
              <div>
                <p className="text-gray-500 dark:text-dark-300">Top Return</p>
                <p className="font-medium text-emerald-600 dark:text-emerald-400">+{q.topReturn}%</p>
              </div>
              <div>
                <p className="text-gray-500 dark:text-dark-300">Exceptions</p>
                <p className="font-medium text-gray-800 dark:text-dark-50">{q.exceptions}</p>
              </div>
              <div>
                <p className="text-gray-500 dark:text-dark-300">Resolved</p>
                <p className="font-medium text-emerald-600 dark:text-emerald-400">{q.resolved}/{q.exceptions}</p>
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
