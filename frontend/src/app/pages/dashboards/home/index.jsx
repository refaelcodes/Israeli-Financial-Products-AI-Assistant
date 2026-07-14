import { Link } from "react-router";
import { Page } from "components/shared/Page";
import { Card } from "components/ui";
import {
  ChatBubbleLeftRightIcon,
  TableCellsIcon,
  BanknotesIcon,
} from "@heroicons/react/24/outline";
import StatTiles from "./StatTiles";
import AumByManager from "./AumByManager";
import AssetAllocation from "./AssetAllocation";
import FundsByClassification from "./FundsByClassification";
import FeeVsYield from "./FeeVsYield";
import TopFundsTable from "./TopFundsTable";

const QUICK_LINKS = [
  { to: "/questions", Icon: ChatBubbleLeftRightIcon, label: "Ask a question", he: "שאל שאלה" },
  { to: "/holdings", Icon: TableCellsIcon, label: "Holdings", he: "אחזקות" },
  { to: "/funds", Icon: BanknotesIcon, label: "Funds", he: "קרנות" },
];

export default function Home() {
  return (
    <Page title="Fund Market Overview">
      <div className="transition-content w-full px-(--margin-x) pt-5 pb-6 lg:pt-6 space-y-4">
        {/* Header */}
        <div className="flex flex-wrap items-end justify-between gap-2">
          <div>
            <h2 className="text-xl font-medium tracking-wide text-gray-800 dark:text-dark-50">
              Fund Market Overview
            </h2>
            <p className="mt-1 text-sm text-gray-500 dark:text-dark-300">
              Live snapshot of Israeli pension &amp; provident funds — from
              fund_combined_db
            </p>
          </div>
          <span dir="rtl" className="text-sm text-gray-400 dark:text-dark-300">
            סקירת שוק הקרנות — פנסיה וגמל
          </span>
        </div>

        {/* KPI tiles */}
        <StatTiles />

        {/* Charts */}
        <div className="grid grid-cols-1 gap-4 xl:grid-cols-2">
          <AumByManager />
          <AssetAllocation />
          <FundsByClassification />
          <FeeVsYield />
        </div>

        {/* Top funds table */}
        <TopFundsTable />

        {/* Quick links */}
        <Card className="p-4">
          <div className="flex flex-wrap items-center gap-3">
            <span className="text-xs font-medium text-gray-500 dark:text-dark-300">
              Explore · המשך לחקור:
            </span>
            {QUICK_LINKS.map(({ to, Icon, label, he }) => (
              <Link
                key={to}
                to={to}
                className="inline-flex items-center gap-2 rounded-lg border border-gray-300 px-3 py-1.5 text-sm text-gray-700 transition-colors hover:border-primary-400 hover:text-primary-600 dark:border-dark-450 dark:text-dark-100 dark:hover:border-primary-400 dark:hover:text-primary-400"
              >
                <Icon className="size-4" />
                {label}
                <span dir="rtl" className="text-[11px] text-gray-400 dark:text-dark-300">
                  {he}
                </span>
              </Link>
            ))}
          </div>
        </Card>
      </div>
    </Page>
  );
}
