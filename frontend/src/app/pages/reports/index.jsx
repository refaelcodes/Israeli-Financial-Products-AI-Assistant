import { NavLink, Outlet } from "react-router";
import { Page } from "components/shared/Page";
import clsx from "clsx";

const tabs = [
  { label: "Quarterly", to: "/reports/quarterly" },
  { label: "Year over Year", to: "/reports/yoy" },
  { label: "Risk", to: "/reports/risk" },
];

export default function ReportsLayout() {
  return (
    <Page title="Reports">
      <div className="transition-content w-full px-(--margin-x) pt-5 pb-6 lg:pt-6 space-y-4">
        <div>
          <h2 className="text-xl font-medium tracking-wide text-gray-800 dark:text-dark-50">
            Reports
          </h2>
          <p className="mt-1 text-sm text-gray-500 dark:text-dark-300">
            Quarterly performance, year-over-year analysis, and risk monitoring
          </p>
        </div>

        <div className="flex gap-1 border-b border-gray-200 dark:border-dark-500">
          {tabs.map((tab) => (
            <NavLink
              key={tab.to}
              to={tab.to}
              className={({ isActive }) =>
                clsx(
                  "px-4 py-2.5 text-sm font-medium transition-colors",
                  isActive
                    ? "border-b-2 border-primary-500 text-primary-600 dark:text-primary-400"
                    : "text-gray-500 hover:text-gray-700 dark:text-dark-300 dark:hover:text-dark-100"
                )
              }
            >
              {tab.label}
            </NavLink>
          ))}
        </div>

        <Outlet />
      </div>
    </Page>
  );
}
