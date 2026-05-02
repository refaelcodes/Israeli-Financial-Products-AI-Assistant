import { useState, useMemo } from "react";
import { AgGridReact } from "ag-grid-react";
import { Card } from "components/ui";
import { Badge } from "components/ui";
import { Button } from "components/ui";
import { MagnifyingGlassIcon, PlusIcon } from "@heroicons/react/24/outline";

const mappings = [
  { id: 1, sourceField: "sec_id", targetField: "isin", source: "Menora", mappingType: "Security", rule: "Direct", status: "Active", lastUsed: "2026-02-15" },
  { id: 2, sourceField: "fund_code", targetField: "fund_number", source: "Migdal", mappingType: "Fund", rule: "Lookup", status: "Active", lastUsed: "2026-02-15" },
  { id: 3, sourceField: "ccy_code", targetField: "currency", source: "Bloomberg", mappingType: "Currency", rule: "ISO 4217", status: "Active", lastUsed: "2026-02-15" },
  { id: 4, sourceField: "asset_type", targetField: "asset_class", source: "Harel", mappingType: "Classification", rule: "Custom Map", status: "Active", lastUsed: "2026-02-14" },
  { id: 5, sourceField: "counterparty_id", targetField: "institution_code", source: "Phoenix", mappingType: "Institution", rule: "Lookup", status: "Active", lastUsed: "2026-02-14" },
  { id: 6, sourceField: "risk_cat", targetField: "risk_level", source: "Internal", mappingType: "Risk", rule: "Enum Map", status: "Active", lastUsed: "2026-02-13" },
  { id: 7, sourceField: "old_ticker", targetField: "isin", source: "TASE", mappingType: "Security", rule: "Legacy Lookup", status: "Deprecated", lastUsed: "2026-01-20" },
  { id: 8, sourceField: "sector_code", targetField: "sector", source: "Altshuler", mappingType: "Classification", rule: "GICS Map", status: "Active", lastUsed: "2026-02-15" },
];

const StatusRenderer = (params) => (
  <Badge variant="soft" color={params.value === "Active" ? "success" : "neutral"} className="text-xs">
    {params.value}
  </Badge>
);

const TypeRenderer = (params) => {
  const colors = { Security: "primary", Fund: "info", Currency: "warning", Classification: "secondary", Institution: "neutral", Risk: "error" };
  return (
    <Badge variant="soft" color={colors[params.value] || "neutral"} className="text-xs">
      {params.value}
    </Badge>
  );
};

export default function Mappings() {
  const [searchText, setSearchText] = useState("");

  const columnDefs = useMemo(() => [
    { field: "source", headerName: "Source", width: 120 },
    { field: "sourceField", headerName: "Source Field", width: 150 },
    { field: "targetField", headerName: "Target Field", width: 150 },
    { field: "mappingType", headerName: "Type", width: 130, cellRenderer: TypeRenderer },
    { field: "rule", headerName: "Rule", width: 130 },
    { field: "status", headerName: "Status", width: 110, cellRenderer: StatusRenderer },
    { field: "lastUsed", headerName: "Last Used", width: 120 },
  ], []);

  const defaultColDef = useMemo(() => ({ sortable: true, filter: true, resizable: true }), []);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <span className="text-sm text-gray-500 dark:text-dark-300">{mappings.length} mappings</span>
        <Button variant="filled" color="primary" className="gap-1.5">
          <PlusIcon className="size-4" />
          Add Mapping
        </Button>
      </div>
      <Card className="p-4">
        <div className="mb-3">
          <div className="relative max-w-sm">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-gray-400" />
            <input type="text" placeholder="Search mappings..." value={searchText} onChange={(e) => setSearchText(e.target.value)}
              className="w-full rounded-lg border border-gray-300 bg-white py-2 pl-9 pr-3 text-sm outline-none focus:border-primary-400 focus:ring-1 focus:ring-primary-400 dark:border-dark-450 dark:bg-dark-700 dark:text-dark-50" />
          </div>
        </div>
        <div className="ag-theme-quartz dark:ag-theme-quartz-dark w-full" style={{ height: 400 }}>
          <AgGridReact rowData={mappings} columnDefs={columnDefs} defaultColDef={defaultColDef} quickFilterText={searchText} animateRows={true} pagination={true} paginationPageSize={20} />
        </div>
      </Card>
    </div>
  );
}
