import { useCallback, useEffect, useState } from "react";
import { Card, Button, Badge } from "components/ui";
import {
  CpuChipIcon,
  KeyIcon,
  CheckCircleIcon,
  XCircleIcon,
} from "@heroicons/react/24/outline";
import {
  getAiConfig,
  setAiConfig,
  connectAi,
  disconnectAi,
} from "utils/apiService";

// Human labels for the three provider modes.
const MODES = [
  { id: "mock", label: "Mock", hint: "Offline · no key" },
  { id: "api", label: "Claude API", hint: "Anthropic key · billed" },
  { id: "sdk", label: "Claude SDK", hint: "Local Claude subscription" },
];

export default function AiProviderPanel({ onReadyChange }) {
  const [cfg, setCfg] = useState(null);
  const [apiKey, setApiKey] = useState("");
  const [remember, setRemember] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(null);

  const applyCfg = useCallback(
    (next) => {
      setCfg(next);
      onReadyChange?.(!!next?.connected);
    },
    [onReadyChange]
  );

  const refresh = useCallback(async () => {
    try {
      applyCfg(await getAiConfig());
    } catch (err) {
      setError(err.message);
      onReadyChange?.(false);
    }
  }, [applyCfg, onReadyChange]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const run = async (fn) => {
    setBusy(true);
    setError(null);
    try {
      await fn();
      await refresh();
    } catch (err) {
      setError(err.message);
    } finally {
      setBusy(false);
    }
  };

  const selectMode = (mode) => run(() => setAiConfig({ ai_mode: mode }));
  const changeModel = (model) => run(() => setAiConfig({ model }));
  const connect = () =>
    run(() =>
      connectAi({
        mode: cfg.ai_mode,
        apiKey: cfg.ai_mode === "api" ? apiKey : undefined,
        remember,
      })
    );
  const disconnect = () => run(() => disconnectAi(cfg.ai_mode));

  if (!cfg) {
    return (
      <Card className="p-4">
        <p className="text-sm text-gray-500 dark:text-dark-300">
          {error ? `Provider status unavailable: ${error}` : "Loading AI provider…"}
        </p>
      </Card>
    );
  }

  const mode = cfg.ai_mode;

  return (
    <Card className="p-4 space-y-3">
      <div className="flex items-center gap-2">
        <CpuChipIcon className="size-5 text-primary-500 shrink-0" />
        <span className="text-sm font-medium text-gray-800 dark:text-dark-50">
          AI Provider
        </span>
        {cfg.connected ? (
          <Badge variant="soft" color="success" className="gap-1 text-[10px]">
            <CheckCircleIcon className="size-3" /> Connected
          </Badge>
        ) : (
          <Badge variant="soft" color="warning" className="gap-1 text-[10px]">
            <XCircleIcon className="size-3" /> Not connected
          </Badge>
        )}
      </div>

      {/* Mode selector */}
      <div className="flex flex-wrap gap-2">
        {MODES.map((m) => (
          <button
            key={m.id}
            onClick={() => selectMode(m.id)}
            disabled={busy}
            className={
              "rounded-lg border px-3 py-1.5 text-left transition-colors disabled:opacity-50 " +
              (mode === m.id
                ? "border-primary-500 bg-primary-50 dark:bg-primary-500/10"
                : "border-gray-300 hover:border-gray-400 dark:border-dark-450")
            }
          >
            <span className="block text-xs font-medium text-gray-800 dark:text-dark-50">
              {m.label}
            </span>
            <span className="block text-[10px] text-gray-400 dark:text-dark-300">
              {m.hint}
            </span>
          </button>
        ))}
      </div>

      {/* Mode-specific connection controls */}
      {mode === "mock" && (
        <p className="text-xs text-gray-500 dark:text-dark-300">
          Mock mode is offline and needs no key — deterministic SQL from keyword
          heuristics, executed on the live database. Great for demos; switch to
          Claude API or SDK for full natural-language understanding.
        </p>
      )}

      {mode !== "mock" && (
        <div className="space-y-2">
          <label className="block text-[11px] font-medium text-gray-500 dark:text-dark-300">
            Model
          </label>
          <select
            value={cfg.model}
            onChange={(e) => changeModel(e.target.value)}
            disabled={busy}
            className="w-full max-w-xs rounded-lg border border-gray-300 bg-white py-1.5 px-2 text-xs outline-none focus:border-primary-400 dark:border-dark-450 dark:bg-dark-700 dark:text-dark-50"
          >
            {cfg.valid_models.map((m) => (
              <option key={m} value={m}>
                {m}
              </option>
            ))}
          </select>
        </div>
      )}

      {mode === "api" && !cfg.connected && (
        <div className="flex flex-wrap items-center gap-2">
          <div className="relative flex-1 min-w-[16rem]">
            <KeyIcon className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-gray-400" />
            <input
              type="password"
              placeholder="Anthropic API key (sk-ant-…)"
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
              className="w-full rounded-lg border border-gray-300 bg-white py-2 pl-9 pr-3 text-sm outline-none focus:border-primary-400 dark:border-dark-450 dark:bg-dark-700 dark:text-dark-50"
            />
          </div>
          <label className="flex items-center gap-1.5 text-xs text-gray-500 dark:text-dark-300">
            <input
              type="checkbox"
              checked={remember}
              onChange={(e) => setRemember(e.target.checked)}
            />
            Remember
          </label>
          <Button
            color="primary"
            className="shrink-0"
            onClick={connect}
            disabled={busy || !apiKey.trim()}
          >
            Connect
          </Button>
        </div>
      )}

      {mode === "sdk" && !cfg.connected && (
        <div className="flex flex-wrap items-center gap-2">
          <p className="flex-1 min-w-[16rem] text-xs text-gray-500 dark:text-dark-300">
            Uses the Claude Agent SDK via your local <code>claude</code> login —
            no API key. Requires the <code>claude-agent-sdk</code> package on the
            backend.
          </p>
          <label className="flex items-center gap-1.5 text-xs text-gray-500 dark:text-dark-300">
            <input
              type="checkbox"
              checked={remember}
              onChange={(e) => setRemember(e.target.checked)}
            />
            Remember
          </label>
          <Button color="primary" className="shrink-0" onClick={connect} disabled={busy}>
            Connect
          </Button>
        </div>
      )}

      {mode !== "mock" && cfg.connected && (
        <div className="flex items-center gap-2">
          <span className="text-xs text-emerald-600 dark:text-emerald-400">
            {mode === "api" ? "API key connected." : "Claude SDK connected."}
          </span>
          <Button variant="soft" color="neutral" className="shrink-0" onClick={disconnect} disabled={busy}>
            Disconnect
          </Button>
        </div>
      )}

      {error && (
        <p className="text-xs text-red-600 dark:text-red-400">⚠ {error}</p>
      )}
    </Card>
  );
}
