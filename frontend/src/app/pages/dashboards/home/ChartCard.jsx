import { Card } from "components/ui";

// Bilingual (EN + Hebrew) card wrapper with loading / error / empty states,
// so a single failing query never blanks the dashboard.
export default function ChartCard({
  title,
  titleHe,
  hint,
  loading,
  error,
  isEmpty,
  height = 300,
  children,
}) {
  return (
    <Card className="p-4">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <h3 className="text-sm font-medium text-gray-800 dark:text-dark-50">
            {title}
          </h3>
          {hint && (
            <p className="mt-0.5 text-[11px] text-gray-400 dark:text-dark-300">
              {hint}
            </p>
          )}
        </div>
        <span
          dir="rtl"
          className="shrink-0 text-xs text-gray-400 dark:text-dark-300"
        >
          {titleHe}
        </span>
      </div>

      <div className="mt-3" style={{ minHeight: height }}>
        {loading ? (
          <div className="flex h-full items-center justify-center py-10 text-xs text-gray-400">
            <div className="size-4 animate-spin rounded-full border-2 border-primary-400 border-t-transparent" />
            <span className="ml-2">Loading…</span>
          </div>
        ) : error ? (
          <div className="rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-xs text-red-700 dark:bg-red-900/20 dark:border-red-800 dark:text-red-400">
            ⚠ {error}
          </div>
        ) : isEmpty ? (
          <div className="flex h-full items-center justify-center py-10 text-xs text-gray-400 dark:text-dark-300">
            No data for this period.
          </div>
        ) : (
          children
        )}
      </div>
    </Card>
  );
}
