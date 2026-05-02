import { useState, useMemo } from "react";
import { AgGridReact } from "ag-grid-react";
import { Card } from "components/ui";
import { Badge } from "components/ui";
import { Button } from "components/ui";
import { MagnifyingGlassIcon, PlusIcon } from "@heroicons/react/24/outline";

const institutions = [
  { id: 1, name: "Menora Mivtachim", code: "MENORA", type: "Insurance", fundsManaged: 12, totalAUM: 45200000000, status: "Active", lastSync: "2026-02-15T08:00:00", contact: "Operations Contact", email: "contact-01@example.invalid" },
  { id: 2, name: "Migdal Insurance", code: "MIGDAL", type: "Insurance", fundsManaged: 10, totalAUM: 38500000000, status: "Active", lastSync: "2026-02-15T07:30:00", contact: "Operations Contact", email: "contact-02@example.invalid" },
  { id: 3, name: "Harel Insurance", code: "HAREL", type: "Insurance", fundsManaged: 8, totalAUM: 28900000000, status: "Active", lastSync: "2026-02-14T22:00:00", contact: "Operations Contact", email: "contact-03@example.invalid" },
  { id: 4, name: "The Phoenix", code: "PHOENIX", type: "Insurance", fundsManaged: 7, totalAUM: 22100000000, status: "Active", lastSync: "2026-02-14T20:00:00", contact: "Operations Contact", email: "contact-04@example.invalid" },
  { id: 5, name: "Clal Insurance", code: "CLAL", type: "Insurance", fundsManaged: 6, totalAUM: 19800000000, status: "Active", lastSync: "2026-02-14T18:00:00", contact: "Operations Contact", email: "contact-05@example.invalid" },
  { id: 6, name: "Altshuler Shaham", code: "ALTSHUL", type: "Investment House", fundsManaged: 9, totalAUM: 31200000000, status: "Active", lastSync: "2026-02-15T06:00:00", contact: "Data Contact", email: "contact-06@example.invalid" },
  { id: 7, name: "Psagot Investment", code: "PSAGOT", type: "Investment House", fundsManaged: 5, totalAUM: 7500000000, status: "Active", lastSync: "2026-02-14T16:00:00", contact: "Data Contact", email: "contact-07@example.invalid" },
  { id: 8, name: "Bloomberg", code: "BBG", type: "Data Vendor", fundsManaged: 0, totalAUM: 0, status: "Active", lastSync: "2026-02-15T08:15:00", contact: "Vendor Support", email: "vendor-01@example.invalid" },
  { id: 9, name: "TASE", code: "TASE", type: "Exchange", fundsManaged: 0, totalAUM: 0, status: "Active", lastSync: "2026-02-15T07:00:00", contact: "Data Services", email: "vendor-02@example.invalid" },
];

const StatusRenderer = (params) => (
  <Badge variant="soft" color={params.value === "Active" ? "success" : "neutral"} className="text-xs">
    {params.value}
  </Badge>
);

const TypeRenderer = (params) => {
  const colors = { Insurance: "primary", "Investment House": "secondary", "Data Vendor": "info", Exchange: "warning" };
  return (
    <Badge variant="soft" color={colors[params.value] || "neutral"} className="text-xs">
      {params.value}
    </Badge>
  );
};

export default function Institutions() {
  const [searchText, setSearchText] = useState("");

  const columnDefs = useMemo(() => [
    { field: "code", headerName: "Code", width: 100, pinned: "left" },
    { field: "name", headerName: "Institution Name", width: 200 },
    { field: "type", headerName: "Type", width: 150, cellRenderer: TypeRenderer },
    { field: "fundsManaged", headerName: "Funds", width: 90, type: "numericColumn" },
    { field: "totalAUM", headerName: "Total AUM", width: 140, type: "numericColumn", valueFormatter: (p) => p.value ? new Intl.NumberFormat("en-US", { style: "currency", currency: "ILS", notation: "compact" }).format(p.value) : "N/A" },
    { field: "status", headerName: "Status", width: 100, cellRenderer: StatusRenderer },
    { field: "contact", headerName: "Contact", width: 130 },
    { field: "email", headerName: "Email", width: 180 },
    { field: "lastSync", headerName: "Last Sync", width: 160, valueFormatter: (p) => p.value ? new Date(p.value).toLocaleString() : "" },
  ], []);

  const defaultColDef = useMemo(() => ({ sortable: true, filter: true, resizable: true }), []);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <span className="text-sm text-gray-500 dark:text-dark-300">{institutions.length} institutions</span>
        <Button variant="filled" color="primary" className="gap-1.5">
          <PlusIcon className="size-4" />
          Add Institution
        </Button>
      </div>
      <Card className="p-4">
        <div className="mb-3">
          <div className="relative max-w-sm">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-gray-400" />
            <input type="text" placeholder="Search institutions..." value={searchText} onChange={(e) => setSearchText(e.target.value)}
              className="w-full rounded-lg border border-gray-300 bg-white py-2 pl-9 pr-3 text-sm outline-none focus:border-primary-400 focus:ring-1 focus:ring-primary-400 dark:border-dark-450 dark:bg-dark-700 dark:text-dark-50" />
          </div>
        </div>
        <div className="ag-theme-quartz dark:ag-theme-quartz-dark w-full" style={{ height: 400 }}>
          <AgGridReact rowData={institutions} columnDefs={columnDefs} defaultColDef={defaultColDef} quickFilterText={searchText} animateRows={true} pagination={true} paginationPageSize={20} />
        </div>
      </Card>
    </div>
  );
}
