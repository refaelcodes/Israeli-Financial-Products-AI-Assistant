import { useState, useMemo, useCallback } from "react";
import { AgGridReact } from "ag-grid-react";
import { Page } from "components/shared/Page";
import { Card } from "components/ui";
import { Badge } from "components/ui";
import { Button } from "components/ui";
import { exceptions } from "./mockData";
import {
  MagnifyingGlassIcon,
  ExclamationCircleIcon,
  ExclamationTriangleIcon,
  InformationCircleIcon,
  CheckCircleIcon,
} from "@heroicons/react/24/outline";

const SeverityRenderer = (params) => {
  const map = {
    error: { color: "error", Icon: ExclamationCircleIcon },
    warning: { color: "warning", Icon: ExclamationTriangleIcon },
    info: { color: "info", Icon: InformationCircleIcon },
  };
  const cfg = map[params.value] || map.info;
  return (
    <Badge variant="soft" color={cfg.color} className="gap-1 text-xs">
      <cfg.Icon className="size-3" />
      {params.value}
    </Badge>
  );
};

const StatusRenderer = (params) => {
  const colorMap = {
    open: "error",
    investigating: "warning",
    resolved: "success",
  };
  return (
    <Badge variant="soft" color={colorMap[params.value] || "neutral"} className="text-xs">
      {params.value}
    </Badge>
  );
};

export default function ValidationExceptions() {
  const [searchText, setSearchText] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");

  const columnDefs = useMemo(
    () => [
      { field: "ruleId", headerName: "Rule", width: 100, pinned: "left" },
      { field: "ruleName", headerName: "Rule Name", width: 160 },
      { field: "severity", headerName: "Severity", width: 120, cellRenderer: SeverityRenderer },
      { field: "status", headerName: "Status", width: 120, cellRenderer: StatusRenderer },
      { field: "source", headerName: "Source", width: 150 },
      { field: "security", headerName: "Security", width: 220 },
      { field: "field", headerName: "Field", width: 110 },
      { field: "expected", headerName: "Expected", width: 120 },
      { field: "actual", headerName: "Actual", width: 130 },
      { field: "assignee", headerName: "Assignee", width: 110 },
      { field: "ingestionRun", headerName: "Ingestion Run", width: 200 },
      { field: "detectedAt", headerName: "Detected At", width: 160, valueFormatter: (p) => p.value ? new Date(p.value).toLocaleString() : "" },
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

  const filteredData = useMemo(() => {
    if (statusFilter === "all") return exceptions;
    return exceptions.filter((e) => e.status === statusFilter);
  }, [statusFilter]);

  const onGridReady = useCallback((params) => {
    params.api.sizeColumnsToFit();
  }, []);

  const counts = useMemo(() => ({
    all: exceptions.length,
    open: exceptions.filter((e) => e.status === "open").length,
    investigating: exceptions.filter((e) => e.status === "investigating").length,
    resolved: exceptions.filter((e) => e.status === "resolved").length,
    errors: exceptions.filter((e) => e.severity === "error").length,
    warnings: exceptions.filter((e) => e.severity === "warning").length,
  }), []);

  return (
    <Page title="Validation / Exceptions">
      <div className="transition-content w-full px-(--margin-x) pt-5 pb-6 lg:pt-6 space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-xl font-medium tracking-wide text-gray-800 dark:text-dark-50">
              Validation / Exceptions
            </h2>
            <p className="mt-1 text-sm text-gray-500 dark:text-dark-300">
              Data quality rules and exception management
            </p>
          </div>
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
          <Card className="p-3">
            <div className="flex items-center gap-2">
              <ExclamationCircleIcon className="size-5 text-red-500" />
              <div>
                <p className="text-lg font-semibold text-gray-800 dark:text-dark-50">{counts.errors}</p>
                <p className="text-xs text-gray-500 dark:text-dark-300">Errors</p>
              </div>
            </div>
          </Card>
          <Card className="p-3">
            <div className="flex items-center gap-2">
              <ExclamationTriangleIcon className="size-5 text-amber-500" />
              <div>
                <p className="text-lg font-semibold text-gray-800 dark:text-dark-50">{counts.warnings}</p>
                <p className="text-xs text-gray-500 dark:text-dark-300">Warnings</p>
              </div>
            </div>
          </Card>
          <Card className="p-3">
            <div className="flex items-center gap-2">
              <ExclamationCircleIcon className="size-5 text-orange-500" />
              <div>
                <p className="text-lg font-semibold text-gray-800 dark:text-dark-50">{counts.open}</p>
                <p className="text-xs text-gray-500 dark:text-dark-300">Open</p>
              </div>
            </div>
          </Card>
          <Card className="p-3">
            <div className="flex items-center gap-2">
              <CheckCircleIcon className="size-5 text-emerald-500" />
              <div>
                <p className="text-lg font-semibold text-gray-800 dark:text-dark-50">{counts.resolved}</p>
                <p className="text-xs text-gray-500 dark:text-dark-300">Resolved</p>
              </div>
            </div>
          </Card>
        </div>

        <Card className="p-4">
          <div className="mb-3 flex items-center gap-3 flex-wrap">
            <div className="relative flex-1 max-w-sm">
              <MagnifyingGlassIcon className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search exceptions..."
                value={searchText}
                onChange={(e) => setSearchText(e.target.value)}
                className="w-full rounded-lg border border-gray-300 bg-white py-2 pl-9 pr-3 text-sm outline-none focus:border-primary-400 focus:ring-1 focus:ring-primary-400 dark:border-dark-450 dark:bg-dark-700 dark:text-dark-50"
              />
            </div>
            <div className="flex gap-1">
              {["all", "open", "investigating", "resolved"].map((s) => (
                <Button
                  key={s}
                  variant={statusFilter === s ? "filled" : "flat"}
                  color={statusFilter === s ? "primary" : "neutral"}
                  className="text-xs capitalize px-3 py-1.5"
                  onClick={() => setStatusFilter(s)}
                >
                  {s} ({counts[s]})
                </Button>
              ))}
            </div>
          </div>

          <div className="ag-theme-quartz dark:ag-theme-quartz-dark w-full" style={{ height: 420 }}>
            <AgGridReact
              rowData={filteredData}
              columnDefs={columnDefs}
              defaultColDef={defaultColDef}
              onGridReady={onGridReady}
              quickFilterText={searchText}
              animateRows={true}
              rowSelection="multiple"
              pagination={true}
              paginationPageSize={20}
            />
          </div>
        </Card>
      </div>
    </Page>
  );
}
