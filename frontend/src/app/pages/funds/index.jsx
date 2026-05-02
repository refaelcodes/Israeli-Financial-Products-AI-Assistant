import { NavLink, Outlet } from "react-router";
import clsx from "clsx";

const tabs = [
  { label: "Pensia", to: "/funds/pensia" },
  { label: "Gemel", to: "/funds/gemel" },
];

export default function FundsLayout() {
  return (
    <div className="transition-content w-full px-(--margin-x) pt-5 pb-6 lg:pt-6 space-y-4">
      <div>
        <h2 className="text-xl font-medium tracking-wide text-gray-800 dark:text-dark-50">
          Funds
        </h2>
        <p className="mt-1 text-sm text-gray-500 dark:text-dark-300">
          Pensia and Gemel fund management
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
  );
}
