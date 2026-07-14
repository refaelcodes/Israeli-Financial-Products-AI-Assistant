import { useState, useCallback, useMemo } from "react";
import { Page } from "components/shared/Page";
import { Card } from "components/ui";
import { Button } from "components/ui";
import { Badge } from "components/ui";
import { AgGridReact } from "ag-grid-react";
import {
  ChatBubbleLeftRightIcon,
  PaperAirplaneIcon,
  ClockIcon,
  CheckCircleIcon,
  QuestionMarkCircleIcon,
  TableCellsIcon,
  ExclamationCircleIcon,
} from "@heroicons/react/24/outline";
import { askQuestion } from "utils/apiService";
import AiProviderPanel from "./AiProviderPanel";

const statusConfig = {
  answered: { color: "success", Icon: CheckCircleIcon, label: "Answered" },
  pending: { color: "warning", Icon: ClockIcon, label: "Processing..." },
  error: { color: "error", Icon: ExclamationCircleIcon, label: "Error" },
};

export default function ClientQuestions() {
  const [inputValue, setInputValue] = useState("");
  const [questions, setQuestions] = useState([]);
  const [submitting, setSubmitting] = useState(false);
  const [history, setHistory] = useState([]);
  const [providerReady, setProviderReady] = useState(true);

  const defaultColDef = useMemo(() => ({
    sortable: true,
    filter: true,
    resizable: true,
  }), []);

  const handleAsk = useCallback(async () => {
    const q = inputValue.trim();
    if (!q || submitting) return;

    const newQ = {
      id: Date.now(),
      question: q,
      status: "pending",
      askedAt: new Date().toISOString(),
      sql: null,
      explanation: null,
      columns: null,
      data: null,
      error: null,
      rowCount: 0,
    };

    setQuestions((prev) => [newQ, ...prev]);
    setInputValue("");
    setSubmitting(true);

    try {
      const result = await askQuestion(q, history);

      setQuestions((prev) =>
        prev.map((item) =>
          item.id === newQ.id
            ? {
                ...item,
                status: result.error ? "error" : "answered",
                sql: result.sql || null,
                explanation: result.explanation || null,
                columns: result.columns || null,
                data: result.data || null,
                error: result.error || null,
                rowCount: result.row_count || 0,
              }
            : item
        )
      );

      // Update conversation history for AI context
      setHistory((prev) => [
        ...prev.slice(-4),
        { role: "user", content: q },
        { role: "assistant", content: result.sql || result.explanation || "" },
      ]);
    } catch (err) {
      setQuestions((prev) =>
        prev.map((item) =>
          item.id === newQ.id
            ? { ...item, status: "error", error: err.message }
            : item
        )
      );
    } finally {
      setSubmitting(false);
    }
  }, [inputValue, submitting, history]);

  const handleKeyDown = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleAsk();
    }
  };

  return (
    <Page title="Client Questions">
      <div className="transition-content w-full px-(--margin-x) pt-5 pb-6 lg:pt-6 space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-xl font-medium tracking-wide text-gray-800 dark:text-dark-50">
              Client Questions
            </h2>
            <p className="mt-1 text-sm text-gray-500 dark:text-dark-300">
              Ask questions in Hebrew / English — AI translates to SQL, executes on fund_combined_db
            </p>
          </div>
          <div className="flex items-center gap-2 text-xs text-gray-500 dark:text-dark-300">
            <Badge variant="soft" color="success" className="text-xs">
              {questions.filter((q) => q.status === "answered").length} answered
            </Badge>
          </div>
        </div>

        {/* AI provider mode: Mock / Claude API / Claude SDK */}
        <AiProviderPanel onReadyChange={setProviderReady} />

        {/* Ask a question */}
        <Card className="p-4">
          <div className="flex items-center gap-3">
            <ChatBubbleLeftRightIcon className="size-5 text-primary-500 shrink-0" />
            <input
              type="text"
              placeholder="שאל שאלה על נתוני הקרנות / Ask a question about fund data..."
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyDown={handleKeyDown}
              disabled={submitting || !providerReady}
              className="flex-1 rounded-lg border border-gray-300 bg-white py-2.5 px-4 text-sm outline-none focus:border-primary-400 focus:ring-1 focus:ring-primary-400 dark:border-dark-450 dark:bg-dark-700 dark:text-dark-50 disabled:opacity-50"
              dir="auto"
            />
            <Button
              variant="filled"
              color="primary"
              className="gap-1.5 shrink-0"
              onClick={handleAsk}
              disabled={submitting || !inputValue.trim() || !providerReady}
            >
              <PaperAirplaneIcon className="size-4" />
              {submitting ? "Asking..." : "Ask"}
            </Button>
          </div>
          {!providerReady && (
            <p className="mt-2 text-[11px] text-amber-600 dark:text-amber-400 pl-8">
              Connect an AI provider above (or switch to Mock) to ask questions.
            </p>
          )}
          <p className="mt-2 text-[11px] text-gray-400 dark:text-dark-400 pl-8">
            Examples: &quot;מהן 10 הקרנות עם התשואה הגבוהה ביותר?&quot; · &quot;Total AUM by managing corporation&quot; · &quot;Top ETFs by fair value&quot;
          </p>
        </Card>

        {/* No questions yet */}
        {questions.length === 0 && (
          <Card className="p-8 text-center">
            <QuestionMarkCircleIcon className="size-12 text-gray-300 dark:text-dark-500 mx-auto mb-3" />
            <p className="text-sm text-gray-500 dark:text-dark-300">
              No questions yet. Type a question above to query the fund database.
            </p>
          </Card>
        )}

        {/* Question/Answer cards */}
        <div className="space-y-3">
          {questions.map((q) => {
            const sCfg = statusConfig[q.status] || statusConfig.pending;
            return (
              <Card key={q.id} className="p-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <Badge variant="soft" color={sCfg.color} className="text-[10px] px-1.5 gap-1">
                        <sCfg.Icon className="size-3" />
                        {sCfg.label}
                      </Badge>
                      {q.rowCount > 0 && (
                        <Badge variant="soft" color="info" className="text-[10px] px-1.5">
                          {q.rowCount} rows
                        </Badge>
                      )}
                      <span className="text-[11px] text-gray-400 dark:text-dark-400 ml-auto">
                        {new Date(q.askedAt).toLocaleTimeString()}
                      </span>
                    </div>

                    <div className="flex items-start gap-2 mt-2">
                      <QuestionMarkCircleIcon className="size-4 text-primary-500 shrink-0 mt-0.5" />
                      <p className="text-sm font-medium text-gray-800 dark:text-dark-50" dir="auto">
                        {q.question}
                      </p>
                    </div>

                    {/* Error */}
                    {q.error && (
                      <div className="mt-3 rounded-lg bg-red-50 border border-red-200 p-3 dark:bg-red-900/20 dark:border-red-800">
                        <p className="text-xs text-red-700 dark:text-red-400">{q.error}</p>
                      </div>
                    )}

                    {/* SQL + Explanation */}
                    {q.sql && (
                      <div className="mt-3 rounded-lg bg-gray-50 p-3 dark:bg-dark-600">
                        <div className="flex items-center gap-1.5 mb-1.5">
                          <TableCellsIcon className="size-3.5 text-emerald-500" />
                          <span className="text-[11px] font-medium text-emerald-600 dark:text-emerald-400">
                            SQL Query
                          </span>
                        </div>
                        <code className="block text-xs text-gray-600 dark:text-dark-200 font-mono break-all whitespace-pre-wrap">
                          {q.sql}
                        </code>
                        {q.explanation && (
                          <p className="mt-2 text-xs text-gray-500 dark:text-dark-300 border-t border-gray-200 dark:border-dark-500 pt-2" dir="auto">
                            {q.explanation}
                          </p>
                        )}
                      </div>
                    )}

                    {/* Result Grid */}
                    {q.data && q.data.length > 0 && q.columns && (
                      <div className="mt-3">
                        <div className="ag-theme-quartz dark:ag-theme-quartz-dark w-full" style={{ height: Math.min(250, 42 + q.data.length * 32) }}>
                          <AgGridReact
                            rowData={q.data}
                            columnDefs={q.columns.map((col) => ({
                              field: col,
                              headerName: col,
                              width: 140,
                            }))}
                            defaultColDef={defaultColDef}
                            suppressHorizontalScroll={false}
                          />
                        </div>
                      </div>
                    )}

                    {/* Honest "no data" state — the query ran but found nothing.
                        Better to say so than to imply an answer that isn't there. */}
                    {q.status === "answered" && q.sql && !q.error && (!q.data || q.data.length === 0) && (
                      <div className="mt-3 rounded-lg bg-gray-50 border border-gray-200 px-3 py-2 text-xs text-gray-500 dark:bg-dark-600 dark:border-dark-500 dark:text-dark-300">
                        No matching rows — the database has no data that answers this
                        question. The query above ran successfully and returned 0 rows.
                      </div>
                    )}

                    {/* Loading spinner */}
                    {q.status === "pending" && (
                      <div className="mt-3 flex items-center gap-2 text-xs text-gray-400">
                        <div className="size-3 border-2 border-primary-400 border-t-transparent rounded-full animate-spin" />
                        Querying database...
                      </div>
                    )}
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      </div>
    </Page>
  );
}
