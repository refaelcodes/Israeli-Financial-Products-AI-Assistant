import { useState, useCallback } from "react";
import { Page } from "components/shared/Page";
import { Button } from "components/ui";
import KanbanColumn from "./KanbanColumn";
import { KANBAN_COLUMNS, initialTasks } from "./mockData";
import { PlusIcon, ArrowPathIcon } from "@heroicons/react/24/outline";

export default function IngestionRuns() {
  const [tasks, setTasks] = useState(initialTasks);
  const [draggingTaskId, setDraggingTaskId] = useState(null);

  const handleDragStart = useCallback((taskId) => {
    setDraggingTaskId(taskId);
  }, []);

  const handleDragEnd = useCallback(() => {
    setDraggingTaskId(null);
  }, []);

  const handleDrop = useCallback(
    (columnId) => {
      if (draggingTaskId == null) return;

      setTasks((prev) =>
        prev.map((t) => {
          if (t.id !== draggingTaskId) return t;

          const updated = { ...t, column: columnId };

          if (columnId === "done") {
            updated.completedAt = new Date().toISOString();
            delete updated.progress;
            delete updated.blockedReason;
          } else if (columnId === "waiting") {
            updated.blockedReason = updated.blockedReason || "Reason not specified";
            delete updated.progress;
            delete updated.completedAt;
          } else if (columnId === "in_process") {
            updated.progress = updated.progress || 0;
            delete updated.blockedReason;
            delete updated.completedAt;
          } else {
            delete updated.progress;
            delete updated.blockedReason;
            delete updated.completedAt;
          }

          return updated;
        })
      );
      setDraggingTaskId(null);
    },
    [draggingTaskId]
  );

  const tasksByColumn = KANBAN_COLUMNS.reduce((acc, col) => {
    acc[col.id] = tasks.filter((t) => t.column === col.id);
    return acc;
  }, {});

  const totalTasks = tasks.length;
  const doneTasks = tasksByColumn.done?.length || 0;

  return (
    <Page title="Ingestion Runs">
      <div className="transition-content w-full px-(--margin-x) pt-5 pb-6 lg:pt-6 space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-xl font-medium tracking-wide text-gray-800 dark:text-dark-50">
              Ingestion Runs
            </h2>
            <p className="mt-1 text-sm text-gray-500 dark:text-dark-300">
              Track data ingestion workflow across all sources
            </p>
          </div>
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 text-xs text-gray-500 dark:text-dark-300">
              <span>{doneTasks}/{totalTasks} completed</span>
              <div className="h-1.5 w-20 rounded-full bg-gray-100 dark:bg-dark-500">
                <div
                  className="h-full rounded-full bg-emerald-500 transition-all"
                  style={{ width: `${totalTasks ? (doneTasks / totalTasks) * 100 : 0}%` }}
                />
              </div>
            </div>
            <Button variant="soft" color="neutral" className="gap-1.5">
              <ArrowPathIcon className="size-4" />
              Refresh
            </Button>
            <Button variant="filled" color="primary" className="gap-1.5">
              <PlusIcon className="size-4" />
              New Run
            </Button>
          </div>
        </div>

        <div
          className="flex gap-4 overflow-x-auto pb-4"
          onDragOver={(e) => e.preventDefault()}
          onDragEnd={handleDragEnd}
        >
          {KANBAN_COLUMNS.map((column) => (
            <KanbanColumn
              key={column.id}
              column={column}
              tasks={tasksByColumn[column.id] || []}
              onDrop={handleDrop}
              onDragStart={handleDragStart}
              draggingTaskId={draggingTaskId}
            />
          ))}
        </div>
      </div>
    </Page>
  );
}
