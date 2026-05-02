import { useState, useMemo } from "react";
import { AgGridReact } from "ag-grid-react";
import { Card } from "components/ui";
import { MagnifyingGlassIcon, ArrowPathIcon } from "@heroicons/react/24/outline";

const aumFormatter = (params) => {
  if (params.value == null) return "";
  // TOTAL_ASSETS is in thousands ILS
  return "₪" + (params.value / 1000).toFixed(1) + "M";
};

const pctFormatter = (params) => {
  if (params.value == null) return "";
  return Number(params.value).toFixed(2) + "%";
};

const yieldCellClass = (params) => {
  if (params.value > 0) return "text-emerald-600 dark:text-emerald-400 font-medium";
  if (params.value < 0) return "text-red-600 dark:text-red-400 font-medium";
  return "";
};

const periodFormatter = (params) => {
  if (!params.value) return "";
  const s = String(Math.round(params.value));
  return s.slice(0, 4) + "/" + s.slice(4);
};

export default function FundGrid({ data, title, loading, error, onRefresh }) {
  const [searchText, setSearchText] = useState("");

  const columnDefs = useMemo(
    () => [
      { field: "FUND_ID", headerName: "Fund ID", width: 90, pinned: "left" },
      { field: "FUND_NAME", headerName: "שם קרן / Fund Name", width: 240, pinned: "left" },
      { field: "MANAGING_CORPORATION", headerName: "חברה מנהלת", width: 200 },
      { field: "FUND_CLASSIFICATION", headerName: "סיווג", width: 130 },
      { field: "REPORT_PERIOD", headerName: "תקופה", width: 100, valueFormatter: periodFormatter },
      { field: "TOTAL_ASSETS", headerName: "AUM (₪K)", width: 120, type: "numericColumn", valueFormatter: aumFormatter },
      { field: "MONTHLY_YIELD", headerName: "Monthly %", width: 100, type: "numericColumn", valueFormatter: pctFormatter, cellClass: yieldCellClass },
      { field: "YEAR_TO_DATE_YIELD", headerName: "YTD %", width: 90, type: "numericColumn", valueFormatter: pctFormatter, cellClass: yieldCellClass },
      { field: "AVG_ANNUAL_YIELD_TRAILING_3YRS", headerName: "3Y Avg %", width: 100, type: "numericColumn", valueFormatter: pctFormatter, cellClass: yieldCellClass },
      { field: "AVG_ANNUAL_YIELD_TRAILING_5YRS", headerName: "5Y Avg %", width: 100, type: "numericColumn", valueFormatter: pctFormatter, cellClass: yieldCellClass },
      { field: "AVG_ANNUAL_MANAGEMENT_FEE", headerName: "Fee %", width: 80, type: "numericColumn", valueFormatter: pctFormatter },
      { field: "SHARPE_RATIO", headerName: "Sharpe", width: 80, type: "numericColumn", valueFormatter: (p) => p.value != null ? Number(p.value).toFixed(2) : "" },
      { field: "STANDARD_DEVIATION", headerName: "Std Dev", width: 90, type: "numericColumn", valueFormatter: (p) => p.value != null ? Number(p.value).toFixed(1) : "" },
      { field: "ALPHA", headerName: "Alpha", width: 80, type: "numericColumn", valueFormatter: (p) => p.value != null ? Number(p.value).toFixed(2) : "" },
      { field: "STOCK_MARKET_EXPOSURE", headerName: "Stocks %", width: 100, type: "numericColumn", valueFormatter: pctFormatter },
      { field: "FOREIGN_EXPOSURE", headerName: "Foreign %", width: 100, type: "numericColumn", valueFormatter: pctFormatter },
      { field: "LIQUID_ASSETS_PERCENT", headerName: "Liquid %", width: 90, type: "numericColumn", valueFormatter: pctFormatter },
      { field: "NET_MONTHLY_DEPOSITS", headerName: "Net Deposits (₪K)", width: 140, type: "numericColumn", valueFormatter: (p) => p.value ? "₪" + (Number(p.value) / 1000).toFixed(0) + "K" : "" },
    ],
    []
  );

  const defaultColDef = useMemo(
    () => ({
      sortable: true,
      filter: true,
      resizable: true,
    }),
    []
  );

  return (
    <Card className="p-4">
      <div className="mb-3 flex items-center gap-3">
        <div className="relative flex-1 max-w-sm">
          <MagnifyingGlassIcon className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder={`Search ${title}...`}
            value={searchText}
            onChange={(e) => setSearchText(e.target.value)}
            className="w-full rounded-lg border border-gray-300 bg-white py-2 pl-9 pr-3 text-sm outline-none focus:border-primary-400 focus:ring-1 focus:ring-primary-400 dark:border-dark-450 dark:bg-dark-700 dark:text-dark-50"
          />
        </div>
        <span className="text-xs text-gray-500 dark:text-dark-300">
          {loading ? "Loading..." : `${data.length} funds`}
        </span>
        {onRefresh && (
          <button
            onClick={onRefresh}
            className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-gray-600 dark:hover:bg-dark-600 dark:hover:text-dark-100 transition-colors"
            title="Refresh from database"
          >
            <ArrowPathIcon className={`size-4 ${loading ? "animate-spin" : ""}`} />
          </button>
        )}
      </div>

      {error && (
        <div className="mb-3 rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-xs text-red-700 dark:bg-red-900/20 dark:border-red-800 dark:text-red-400">
          ⚠ API Error: {error} — showing cached/mock data
        </div>
      )}

      <div className="ag-theme-quartz dark:ag-theme-quartz-dark w-full" style={{ height: 520 }}>
        <AgGridReact
          rowData={data}
          columnDefs={columnDefs}
          defaultColDef={defaultColDef}
          quickFilterText={searchText}
          animateRows={true}
          rowSelection="multiple"
          pagination={true}
          paginationPageSize={50}
          loading={loading}
        />
      </div>
    </Card>
  );
}
