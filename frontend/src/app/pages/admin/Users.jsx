import { useState, useMemo } from "react";
import { AgGridReact } from "ag-grid-react";
import { Card } from "components/ui";
import { Badge } from "components/ui";
import { Button } from "components/ui";
import { MagnifyingGlassIcon, PlusIcon } from "@heroicons/react/24/outline";

const users = [
  { id: 1, name: "Demo Analyst 01", email: "user-01@example.invalid", role: "Data Analyst", department: "Operations", status: "Active", lastLogin: "2026-02-15T08:30:00", tasksAssigned: 5 },
  { id: 2, name: "Demo Analyst 02", email: "user-02@example.invalid", role: "Senior Analyst", department: "Operations", status: "Active", lastLogin: "2026-02-15T07:45:00", tasksAssigned: 4 },
  { id: 3, name: "Demo Analyst 03", email: "user-03@example.invalid", role: "Data Analyst", department: "Operations", status: "Active", lastLogin: "2026-02-14T16:00:00", tasksAssigned: 3 },
  { id: 4, name: "Demo Analyst 04", email: "user-04@example.invalid", role: "Junior Analyst", department: "Operations", status: "Active", lastLogin: "2026-02-14T14:00:00", tasksAssigned: 2 },
  { id: 5, name: "Demo Risk Manager", email: "user-05@example.invalid", role: "Risk Manager", department: "Risk", status: "Active", lastLogin: "2026-02-15T09:00:00", tasksAssigned: 1 },
  { id: 6, name: "Demo Admin", email: "user-06@example.invalid", role: "IT Admin", department: "IT", status: "Active", lastLogin: "2026-02-15T08:00:00", tasksAssigned: 0 },
  { id: 7, name: "Demo Compliance Officer", email: "user-07@example.invalid", role: "Compliance Officer", department: "Compliance", status: "Active", lastLogin: "2026-02-14T17:00:00", tasksAssigned: 0 },
  { id: 8, name: "Demo Analyst 08", email: "user-08@example.invalid", role: "Data Analyst", department: "Operations", status: "Inactive", lastLogin: "2026-01-15T10:00:00", tasksAssigned: 0 },
];

const StatusRenderer = (params) => (
  <Badge variant="soft" color={params.value === "Active" ? "success" : "neutral"} className="text-xs">
    {params.value}
  </Badge>
);

const RoleRenderer = (params) => {
  const colors = { "IT Admin": "error", "Risk Manager": "warning", "Senior Analyst": "primary", "Data Analyst": "info", "Junior Analyst": "neutral", "Compliance Officer": "secondary" };
  return (
    <Badge variant="soft" color={colors[params.value] || "neutral"} className="text-xs">
      {params.value}
    </Badge>
  );
};

export default function Users() {
  const [searchText, setSearchText] = useState("");

  const columnDefs = useMemo(() => [
    { field: "name", headerName: "Name", width: 170, pinned: "left" },
    { field: "email", headerName: "Email", width: 220 },
    { field: "role", headerName: "Role", width: 160, cellRenderer: RoleRenderer },
    { field: "department", headerName: "Department", width: 130 },
    { field: "status", headerName: "Status", width: 100, cellRenderer: StatusRenderer },
    { field: "tasksAssigned", headerName: "Tasks", width: 90, type: "numericColumn" },
    { field: "lastLogin", headerName: "Last Login", width: 160, valueFormatter: (p) => p.value ? new Date(p.value).toLocaleString() : "" },
  ], []);

  const defaultColDef = useMemo(() => ({ sortable: true, filter: true, resizable: true }), []);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <span className="text-sm text-gray-500 dark:text-dark-300">{users.length} users</span>
        <Button variant="filled" color="primary" className="gap-1.5">
          <PlusIcon className="size-4" />
          Add User
        </Button>
      </div>
      <Card className="p-4">
        <div className="mb-3">
          <div className="relative max-w-sm">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-gray-400" />
            <input type="text" placeholder="Search users..." value={searchText} onChange={(e) => setSearchText(e.target.value)}
              className="w-full rounded-lg border border-gray-300 bg-white py-2 pl-9 pr-3 text-sm outline-none focus:border-primary-400 focus:ring-1 focus:ring-primary-400 dark:border-dark-450 dark:bg-dark-700 dark:text-dark-50" />
          </div>
        </div>
        <div className="ag-theme-quartz dark:ag-theme-quartz-dark w-full" style={{ height: 400 }}>
          <AgGridReact rowData={users} columnDefs={columnDefs} defaultColDef={defaultColDef} quickFilterText={searchText} animateRows={true} pagination={true} paginationPageSize={20} />
        </div>
      </Card>
    </div>
  );
}
