import { Card } from "components/ui";
import { Badge } from "components/ui";

const yoyData = [
  { year: 2025, totalReturn: 8.2, equityReturn: 12.5, bondsReturn: 4.1, aumEnd: "₪245.2B", aumGrowth: 7.3, members: 1200000, membersGrowth: 3.2 },
  { year: 2024, totalReturn: 10.5, equityReturn: 15.8, bondsReturn: 3.8, aumEnd: "₪228.4B", aumGrowth: 9.1, members: 1163000, membersGrowth: 4.1 },
  { year: 2023, totalReturn: 6.1, equityReturn: 8.9, bondsReturn: 3.2, aumEnd: "₪209.3B", aumGrowth: 5.8, members: 1117000, membersGrowth: 3.8 },
  { year: 2022, totalReturn: -2.3, equityReturn: -8.5, bondsReturn: 1.2, aumEnd: "₪197.8B", aumGrowth: -1.2, members: 1076000, membersGrowth: 2.9 },
  { year: 2021, totalReturn: 12.8, equityReturn: 18.2, bondsReturn: 5.5, aumEnd: "₪200.2B", aumGrowth: 14.5, members: 1045000, membersGrowth: 4.5 },
];

export default function YoY() {
  return (
    <div className="space-y-4">
      <Card className="overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-200 dark:border-dark-500">
                <th className="px-4 py-3 text-left font-medium text-gray-600 dark:text-dark-200">Year</th>
                <th className="px-4 py-3 text-right font-medium text-gray-600 dark:text-dark-200">Total Return</th>
                <th className="px-4 py-3 text-right font-medium text-gray-600 dark:text-dark-200">Equity</th>
                <th className="px-4 py-3 text-right font-medium text-gray-600 dark:text-dark-200">Bonds</th>
                <th className="px-4 py-3 text-right font-medium text-gray-600 dark:text-dark-200">AUM (End)</th>
                <th className="px-4 py-3 text-right font-medium text-gray-600 dark:text-dark-200">AUM Growth</th>
                <th className="px-4 py-3 text-right font-medium text-gray-600 dark:text-dark-200">Members</th>
                <th className="px-4 py-3 text-right font-medium text-gray-600 dark:text-dark-200">Member Growth</th>
              </tr>
            </thead>
            <tbody>
              {yoyData.map((row) => (
                <tr key={row.year} className="border-b border-gray-100 last:border-0 dark:border-dark-600 hover:bg-gray-50 dark:hover:bg-dark-600/50">
                  <td className="px-4 py-3 font-semibold text-gray-800 dark:text-dark-50">{row.year}</td>
                  <td className="px-4 py-3 text-right">
                    <Badge variant="soft" color={row.totalReturn >= 0 ? "success" : "error"} className="text-xs">
                      {row.totalReturn >= 0 ? "+" : ""}{row.totalReturn}%
                    </Badge>
                  </td>
                  <td className={`px-4 py-3 text-right font-medium ${row.equityReturn >= 0 ? "text-emerald-600 dark:text-emerald-400" : "text-red-600 dark:text-red-400"}`}>
                    {row.equityReturn >= 0 ? "+" : ""}{row.equityReturn}%
                  </td>
                  <td className={`px-4 py-3 text-right font-medium ${row.bondsReturn >= 0 ? "text-emerald-600 dark:text-emerald-400" : "text-red-600 dark:text-red-400"}`}>
                    +{row.bondsReturn}%
                  </td>
                  <td className="px-4 py-3 text-right text-gray-800 dark:text-dark-50">{row.aumEnd}</td>
                  <td className={`px-4 py-3 text-right font-medium ${row.aumGrowth >= 0 ? "text-emerald-600 dark:text-emerald-400" : "text-red-600 dark:text-red-400"}`}>
                    {row.aumGrowth >= 0 ? "+" : ""}{row.aumGrowth}%
                  </td>
                  <td className="px-4 py-3 text-right text-gray-800 dark:text-dark-50">{row.members.toLocaleString()}</td>
                  <td className="px-4 py-3 text-right text-emerald-600 dark:text-emerald-400">+{row.membersGrowth}%</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
