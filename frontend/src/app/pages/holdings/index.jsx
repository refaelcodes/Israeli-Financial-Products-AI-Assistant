import { useState, useMemo, useEffect, useCallback } from "react";
import { AgGridReact } from "ag-grid-react";
import { Page } from "components/shared/Page";
import { Card } from "components/ui";
import { Button } from "components/ui";
import { Badge } from "components/ui";
import {
  MagnifyingGlassIcon,
  FunnelIcon,
  ArrowDownTrayIcon,
  ArrowPathIcon,
} from "@heroicons/react/24/outline";
import clsx from "clsx";
import {
  getAllHoldings,
  getTradedStocks,
  getGovernmentBonds,
  getCorporateBonds,
  getETFs,
} from "utils/apiService";

const fairValueFormatter = (params) => {
  if (params.value == null) return "";
  return "₪" + Number(params.value).toLocaleString() + "K";
};

const pctFormatter = (params) => {
  if (params.value == null) return "";
  return Number(params.value).toFixed(2) + "%";
};

const AssetClassRenderer = (params) => {
  const colorMap = {
    Stocks: "primary",
    "Gov Bonds": "info",
    "Corp Bonds": "warning",
    ETFs: "secondary",
  };
  return (
    <Badge variant="soft" color={colorMap[params.value] || "neutral"} className="text-xs">
      {params.value}
    </Badge>
  );
};

const MarketRenderer = (params) => {
  if (!params.value) return null;
  return (
    <Badge variant="soft" color={params.value === "ישראל" ? "primary" : "secondary"} className="text-xs">
      {params.value}
    </Badge>
  );
};

const tabDefs = [
  { id: "all", label: "All Assets", fetcher: getAllHoldings },
  { id: "stocks", label: "Stocks", fetcher: getTradedStocks },
  { id: "gov_bonds", label: "Gov Bonds", fetcher: getGovernmentBonds },
  { id: "corp_bonds", label: "Corp Bonds", fetcher: getCorporateBonds },
  { id: "etfs", label: "ETFs", fetcher: getETFs },
];

export default function HoldingsExplorer() {
  const [searchText, setSearchText] = useState("");
  const [activeTab, setActiveTab] = useState("all");
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchData = useCallback(async (tabId) => {
    const tab = tabDefs.find((t) => t.id === tabId) || tabDefs[0];
    setLoading(true);
    setError(null);
    try {
      const result = await tab.fetcher();
      setData(result.data || []);
    } catch (err) {
      setError(err.message || "Failed to fetch holdings");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData(activeTab);
  }, [activeTab, fetchData]);

  const handleTabChange = (tabId) => {
    setActiveTab(tabId);
  };

  const columnDefs = useMemo(
    () => [
      { field: "security_id", headerName: "Security ID", width: 150, pinned: "left" },
      { field: "security_name", headerName: "שם נייר ערך", width: 220, pinned: "left" },
      ...(activeTab === "all" ? [{ field: "asset_class", headerName: "Asset Class", width: 120, cellRenderer: AssetClassRenderer }] : []),
      { field: "issuer_name", headerName: "מנפיק", width: 150 },
      { field: "market_type", headerName: "ישראל/חו\"ל", width: 100, cellRenderer: MarketRenderer },
      { field: "exposure_country", headerName: "Country", width: 100 },
      { field: "currency_code", headerName: "CCY", width: 75 },
      { field: "market_price", headerName: "Price", width: 90, type: "numericColumn", valueFormatter: (p) => p.value != null ? Number(p.value).toFixed(2) : "" },
      { field: "fair_value", headerName: "Fair Value (₪K)", width: 140, type: "numericColumn", valueFormatter: fairValueFormatter },
      { field: "asset_class_weight", headerName: "Class %", width: 90, type: "numericColumn", valueFormatter: pctFormatter },
      { field: "total_portfolio_weight", headerName: "Portfolio %", width: 100, type: "numericColumn", valueFormatter: pctFormatter },
      { field: "entity_id", headerName: "Fund ID", width: 90 },
      { field: "report_date", headerName: "Report Date", width: 110 },
    ],
    [activeTab]
  );

  const defaultColDef = useMemo(
    () => ({
      sortable: true,
      filter: true,
      resizable: true,
    }),
    []
  );

  const totalFairValue = data.reduce((sum, h) => sum + (Number(h.fair_value) || 0), 0);

  return (
    <Page title="Holdings Explorer">
      <div className="transition-content w-full px-(--margin-x) pt-5 pb-6 lg:pt-6 space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-xl font-medium tracking-wide text-gray-800 dark:text-dark-50">
              Holdings Explorer
            </h2>
            <p className="mt-1 text-sm text-gray-500 dark:text-dark-300">
              {loading
                ? "Loading asset holdings from database..."
                : `${data.length} holdings — live from fund_combined_db (27 asset tables)`}
            </p>
          </div>
          <div className="flex items-center gap-2">
            <Button variant="soft" color="neutral" className="gap-1.5" onClick={() => fetchData(activeTab)}>
              <ArrowPathIcon className={`size-4 ${loading ? "animate-spin" : ""}`} />
              Refresh
            </Button>
            <Button variant="soft" color="neutral" className="gap-1.5">
              <FunnelIcon className="size-4" />
              Filters
            </Button>
            <Button variant="soft" color="neutral" className="gap-1.5">
              <ArrowDownTrayIcon className="size-4" />
              Export
            </Button>
          </div>
        </div>

        {error && (
          <div className="rounded-lg bg-red-50 border border-red-200 px-4 py-2.5 text-sm text-red-700 dark:bg-red-900/20 dark:border-red-800 dark:text-red-400">
            ⚠ API Error: {error}
          </div>
        )}

        {/* Asset class tabs */}
        <div className="flex gap-1 border-b border-gray-200 dark:border-dark-500">
          {tabDefs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => handleTabChange(tab.id)}
              className={clsx(
                "px-4 py-2.5 text-sm font-medium transition-colors",
                activeTab === tab.id
                  ? "border-b-2 border-primary-500 text-primary-600 dark:text-primary-400"
                  : "text-gray-500 hover:text-gray-700 dark:text-dark-300 dark:hover:text-dark-100"
              )}
            >
              {tab.label}
            </button>
          ))}
        </div>

        <Card className="p-4">
          <div className="mb-3 flex items-center gap-3">
            <div className="relative flex-1 max-w-sm">
              <MagnifyingGlassIcon className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search securities..."
                value={searchText}
                onChange={(e) => setSearchText(e.target.value)}
                className="w-full rounded-lg border border-gray-300 bg-white py-2 pl-9 pr-3 text-sm outline-none focus:border-primary-400 focus:ring-1 focus:ring-primary-400 dark:border-dark-450 dark:bg-dark-700 dark:text-dark-50"
              />
            </div>
            <div className="flex items-center gap-2 text-xs text-gray-500 dark:text-dark-300">
              <span>{loading ? "..." : `${data.length} holdings`}</span>
              <span className="text-gray-300 dark:text-dark-500">|</span>
              <span>Total: ₪{totalFairValue.toLocaleString()}K</span>
            </div>
          </div>

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
      </div>
    </Page>
  );
}
