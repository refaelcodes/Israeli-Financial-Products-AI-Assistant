import { Badge } from "components/ui";
import { ClockIcon, UserIcon, ExclamationTriangleIcon, DocumentIcon } from "@heroicons/react/24/outline";
import clsx from "clsx";

const priorityConfig = {
  high: { color: "error", label: "High" },
  medium: { color: "warning", label: "Medium" },
  low: { color: "info", label: "Low" },
};

export default function KanbanCard({ task, onDragStart, isDragging }) {
  const priority = priorityConfig[task.priority] || priorityConfig.medium;
  const timeAgo = getTimeAgo(task.createdAt);

  return (
    <div
      draggable
      onDragStart={(e) => {
        e.dataTransfer.setData("text/plain", task.id.toString());
        onDragStart(task.id);
      }}
      className={clsx(
        "group cursor-grab rounded-lg border border-gray-200 bg-white p-3 transition-all dark:border-dark-500 dark:bg-dark-700",
        "hover:shadow-md hover:border-gray-300 dark:hover:border-dark-400",
        "active:cursor-grabbing active:shadow-lg",
        isDragging && "opacity-50 rotate-2 scale-95"
      )}
    >
      <div className="flex items-start justify-between gap-2">
        <h4 className="text-sm font-medium text-gray-800 dark:text-dark-50 leading-tight">
          {task.title}
        </h4>
        <Badge variant="soft" color={priority.color} className="shrink-0 text-[10px] px-1.5 py-0.5">
          {priority.label}
        </Badge>
      </div>

      <p className="mt-1 text-xs text-gray-500 dark:text-dark-300">
        {task.source}
      </p>

      {task.blockedReason && (
        <div className="mt-2 flex items-start gap-1.5 rounded-md bg-amber-50 p-2 dark:bg-amber-900/20">
          <ExclamationTriangleIcon className="size-3.5 shrink-0 text-amber-500 mt-0.5" />
          <span className="text-xs text-amber-700 dark:text-amber-400">
            {task.blockedReason}
          </span>
        </div>
      )}

      {task.progress != null && (
        <div className="mt-2">
          <div className="flex items-center justify-between text-[10px] text-gray-500 dark:text-dark-300 mb-1">
            <span>Progress</span>
            <span>{task.progress}%</span>
          </div>
          <div className="h-1.5 w-full rounded-full bg-gray-100 dark:bg-dark-500">
            <div
              className="h-full rounded-full bg-primary-500 transition-all"
              style={{ width: `${task.progress}%` }}
            />
          </div>
        </div>
      )}

      <div className="mt-2.5 flex items-center justify-between text-[11px] text-gray-400 dark:text-dark-400">
        <div className="flex items-center gap-3">
          <span className="flex items-center gap-1">
            <DocumentIcon className="size-3" />
            {task.fileType}
          </span>
          <span>{task.records?.toLocaleString()} rows</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="flex items-center gap-1">
            <UserIcon className="size-3" />
            {task.assignee}
          </span>
        </div>
      </div>

      <div className="mt-1.5 flex items-center gap-1 text-[10px] text-gray-400 dark:text-dark-400">
        <ClockIcon className="size-3" />
        {timeAgo}
      </div>
    </div>
  );
}

function getTimeAgo(dateStr) {
  const now = new Date();
  const date = new Date(dateStr);
  const diffMs = now - date;
  const diffMins = Math.floor(diffMs / 60000);
  const diffHrs = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHrs / 24);

  if (diffMins < 60) return `${diffMins}m ago`;
  if (diffHrs < 24) return `${diffHrs}h ago`;
  return `${diffDays}d ago`;
}
