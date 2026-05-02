import { useState } from "react";
import { Badge } from "components/ui";
import KanbanCard from "./KanbanCard";
import clsx from "clsx";

const columnColors = {
  primary: {
    dot: "bg-primary-500",
    dropzone: "border-primary-300 bg-primary-50/50 dark:border-primary-700 dark:bg-primary-900/10",
  },
  warning: {
    dot: "bg-amber-500",
    dropzone: "border-amber-300 bg-amber-50/50 dark:border-amber-700 dark:bg-amber-900/10",
  },
  info: {
    dot: "bg-sky-500",
    dropzone: "border-sky-300 bg-sky-50/50 dark:border-sky-700 dark:bg-sky-900/10",
  },
  success: {
    dot: "bg-emerald-500",
    dropzone: "border-emerald-300 bg-emerald-50/50 dark:border-emerald-700 dark:bg-emerald-900/10",
  },
};

export default function KanbanColumn({ column, tasks, onDrop, onDragStart, draggingTaskId }) {
  const [isDragOver, setIsDragOver] = useState(false);
  const colors = columnColors[column.color] || columnColors.primary;

  const handleDragOver = (e) => {
    e.preventDefault();
    setIsDragOver(true);
  };

  const handleDragLeave = (e) => {
    if (!e.currentTarget.contains(e.relatedTarget)) {
      setIsDragOver(false);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragOver(false);
    onDrop(column.id);
  };

  return (
    <div
      className={clsx(
        "flex min-w-[280px] max-w-[320px] flex-1 flex-col rounded-xl border-2 border-dashed transition-colors",
        isDragOver
          ? colors.dropzone
          : "border-transparent"
      )}
      onDragOver={handleDragOver}
      onDragLeave={handleDragLeave}
      onDrop={handleDrop}
    >
      <div className="flex items-center gap-2 px-1 pb-3">
        <div className={clsx("size-2.5 rounded-full", colors.dot)} />
        <h3 className="text-sm font-semibold text-gray-700 dark:text-dark-100">
          {column.title}
        </h3>
        <Badge variant="soft" color="neutral" className="text-[10px] px-1.5 py-0.5 ml-auto">
          {tasks.length}
        </Badge>
      </div>

      <div className="flex flex-1 flex-col gap-2.5 overflow-y-auto px-0.5 pb-2" style={{ maxHeight: "calc(100vh - 260px)" }}>
        {tasks.map((task) => (
          <KanbanCard
            key={task.id}
            task={task}
            onDragStart={onDragStart}
            isDragging={draggingTaskId === task.id}
          />
        ))}

        {tasks.length === 0 && (
          <div className="flex flex-col items-center justify-center rounded-lg border border-dashed border-gray-200 py-8 dark:border-dark-500">
            <p className="text-xs text-gray-400 dark:text-dark-400">
              No tasks
            </p>
            <p className="text-[10px] text-gray-300 dark:text-dark-500 mt-1">
              Drag tasks here
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
