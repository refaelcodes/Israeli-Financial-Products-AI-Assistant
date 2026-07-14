#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ai_provider.py
==============
AI-provider abstraction for the "Client Questions" feature — the heart of the
NL-to-SQL mode switch.

A single interface `AIProvider.ask(question, history) -> {"sql", "explanation"}`
hides the transport behind three interchangeable modes:

    ApiProvider   ai_mode="api"   direct Anthropic Messages API (needs ANTHROPIC_API_KEY; billed)
    SdkProvider   ai_mode="sdk"   Claude Agent SDK (claude_agent_sdk) via a Claude subscription
    MockProvider  ai_mode="mock"  offline — deterministic heuristic SQL, no network, no key

All three honor the same tool contract (`SQL_TOOL`), so the JSON shape returned
is identical regardless of how it was produced. The api/sdk modes force the
model to emit structured `{sql, explanation}` via tool use; the mock mode builds
a safe SELECT from lightweight keyword heuristics so the page stays fully
functional — and demoable — with no API key.
"""

import os
import re
import asyncio

# Model ids verified against the Claude API (Opus 4.8 is the current default).
VALID_MODELS = [
    "claude-opus-4-8",
    "claude-sonnet-5",
    "claude-haiku-4-5",
    "claude-fable-5",
]
VALID_MODES = ("api", "sdk", "mock")
DEFAULT_MODEL = "claude-opus-4-8"

# ── Structured-output contract ───────────────────────────────────────────────
# A single tool the model is forced to call. Its arguments ARE the result, so
# the output shape is identical across api/sdk modes (and mirrored by mock).
SQL_TOOL = {
    "name": "run_sql_query",
    "description": (
        "Return a single read-only SQLite SELECT query that answers the user's "
        "question about the Israeli pension/provident fund database, together "
        "with a short explanation. Call this tool exactly once."
    ),
    "input_schema": {
        "type": "object",
        "properties": {
            "sql": {
                "type": "string",
                "description": "A single read-only SQLite query (SELECT or WITH ... SELECT). "
                               "No INSERT/UPDATE/DELETE/DROP/ALTER/CREATE/PRAGMA.",
            },
            "explanation": {
                "type": "string",
                "description": "1-3 sentence explanation of what the query does, "
                               "written in the same language as the user's question.",
            },
        },
        "required": ["sql"],
    },
}


def build_system_prompt(schema_text: str) -> str:
    """Compose the NL-to-SQL system prompt from the compact DB schema."""
    return f"""You are an AI assistant for the Israeli Pension & Provident Fund database.
You translate natural-language questions into SQLite SQL queries.

DATABASE SCHEMA:
{schema_text}

RULES:
1. Use SELECT only — never INSERT, UPDATE, DELETE, DROP, ALTER, CREATE, PRAGMA.
2. Quote table names with double quotes when they start with uppercase: "Gemel", "Pensia".
3. For the latest data use: WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "Gemel").
4. REPORT_PERIOD is numeric YYYYMM (e.g. 202412) — do not treat it as a date string.
5. Yield/fee columns are already percentages (1.5 means 1.5%). TOTAL_ASSETS is in thousands of ILS.
6. To combine gemel + pensia use UNION ALL with matching columns.
7. To join fund stats with asset tables: CAST(g.FUND_ID AS INTEGER) = CAST(a.entity_id AS INTEGER).
8. LIMIT results to 50 unless the user asks for more.
9. Sort by the most relevant metric (e.g. yield DESC for "best funds").
10. The user may write in Hebrew, Russian, or English. Write the explanation in the user's language.
    Hebrew: תשואה = yield, נכסים = assets, דמי ניהול = management fee, סיכון = risk.
    Russian: доходность = yield, комиссия = management fee, фонд = fund.
11. If the question is ambiguous, make a reasonable assumption and note it in the explanation.

Call the tool `run_sql_query` exactly once with the SQL and a brief explanation."""


def _history_messages(history):
    """Convert the frontend conversation history into Messages-API messages."""
    messages = []
    for msg in (history or [])[-6:]:
        role = (msg.get("role") or "").lower()
        content = msg.get("content")
        if role in ("user", "assistant") and content:
            messages.append({"role": role, "content": str(content)})
    return messages


def _extract_tool_input(response):
    """Pull the run_sql_query arguments from a Messages-API response (or dict stub)."""
    blocks = response["content"] if isinstance(response, dict) else response.content
    for b in blocks:
        btype = b["type"] if isinstance(b, dict) else b.type
        if btype == "tool_use":
            data = b["input"] if isinstance(b, dict) else b.input
            return {"sql": (data.get("sql") or "").strip(),
                    "explanation": (data.get("explanation") or "").strip()}
    raise RuntimeError("Model did not call run_sql_query — no structured SQL returned")


# ═══════════════════════════════════════════════════════════════ providers
class AIProvider:
    """Base interface. Subclasses implement ask()."""
    mode = "base"

    def __init__(self, model=DEFAULT_MODEL, system_prompt="", max_tokens=2048, api_key=None):
        self.model = model or DEFAULT_MODEL
        self.system_prompt = system_prompt
        self.max_tokens = max_tokens
        self.api_key = api_key  # from UI (in-memory), takes priority over ANTHROPIC_API_KEY

    def ask(self, question, history=None) -> dict:
        raise NotImplementedError

    def info(self) -> dict:
        return {"mode": self.mode, "model": self.model}


class ApiProvider(AIProvider):
    """Direct Anthropic Messages API — forces structured output via tool_choice."""
    mode = "api"

    def ask(self, question, history=None) -> dict:
        import anthropic

        key = self.api_key or os.environ.get("ANTHROPIC_API_KEY", "").strip()
        if not key:
            raise ValueError("No Anthropic API key. Connect one in the UI or set ANTHROPIC_API_KEY.")

        client = anthropic.Anthropic(api_key=key)
        messages = _history_messages(history)
        messages.append({"role": "user", "content": str(question)})

        response = client.messages.create(
            model=self.model,
            max_tokens=self.max_tokens,
            system=self.system_prompt,
            tools=[SQL_TOOL],
            tool_choice={"type": "tool", "name": "run_sql_query"},  # force structured SQL
            messages=messages,
        )
        return _extract_tool_input(response)


class SdkProvider(AIProvider):
    """Claude Agent SDK (claude_agent_sdk) via a local Claude subscription.

    Structured output is achieved with an in-process MCP tool `run_sql_query`
    whose handler captures the arguments the model passes (that IS the result).
    Requires the `claude-agent-sdk` package and a working `claude` login.
    """
    mode = "sdk"

    def ask(self, question, history=None) -> dict:
        return asyncio.run(self._aask(question, history))

    async def _aask(self, question, history=None) -> dict:
        import claude_agent_sdk as sdk

        captured = {}

        @sdk.tool("run_sql_query", SQL_TOOL["description"], SQL_TOOL["input_schema"])
        async def run_sql_query(args):
            captured["data"] = args
            return {"content": [{"type": "text", "text": "ok"}]}

        server = sdk.create_sdk_mcp_server("sql", tools=[run_sql_query])
        opts = sdk.ClaudeAgentOptions(
            system_prompt=self.system_prompt,
            model=self.model,
            mcp_servers={"sql": server},
            allowed_tools=["mcp__sql__run_sql_query"],
            permission_mode="bypassPermissions",
            setting_sources=[],   # don't pull the host project's CLAUDE.md into the nested agent
            max_turns=3,
        )

        # Fold prior turns into the prompt as lightweight context.
        parts = []
        for m in _history_messages(history):
            parts.append(f"{m['role']}: {m['content']}")
        parts.append(f"user: {question}")
        prompt_text = "\n".join(parts)

        async def prompts():
            yield {"type": "user", "message": {"role": "user", "content": prompt_text}}

        async for _msg in sdk.query(prompt=prompts(), options=opts):
            pass  # the model's tool arguments are captured in run_sql_query

        if "data" not in captured:
            raise RuntimeError("SDK did not call run_sql_query — structured SQL not returned")
        data = captured["data"]
        return {"sql": (data.get("sql") or "").strip(),
                "explanation": (data.get("explanation") or "").strip()}


class MockProvider(AIProvider):
    """Offline, deterministic NL-to-SQL via keyword heuristics — no network, no key.

    Produces a real, safe SELECT against the live DB so the whole pipeline
    (question -> SQL -> execution -> results grid) works with zero configuration.
    Clearly labelled [MOCK] so it's never mistaken for the AI models.
    """
    mode = "mock"

    def ask(self, question, history=None) -> dict:
        q = (question or "").lower()

        # Which table? default to Gemel (the larger population).
        if any(t in q for t in ("pensia", "פנסיה", "פנסי", "пенси")):
            table, table_label = "Pensia", "pension"
        else:
            table, table_label = "Gemel", "provident"

        # Row limit — honor an explicit number, else 10.
        m = re.search(r"\b(\d{1,3})\b", q)
        limit = min(int(m.group(1)), 200) if m else 10

        # Count questions.
        if any(w in q for w in ("how many", "count", "כמה", "מספר", "сколько", "количеств")):
            sql = (f'SELECT COUNT(*) AS fund_count FROM "{table}" '
                   f'WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "{table}")')
            return {"sql": sql,
                    "explanation": f"[MOCK] Offline heuristic query: counts {table_label} funds "
                                   f"in the latest reporting period. Connect Claude API or SDK for full NL understanding."}

        # Pick a metric + sort direction from keywords.
        if any(w in q for w in ("fee", "management", "דמי ניהול", "עמלה", "комисс")):
            metric, direction, label = "AVG_ANNUAL_MANAGEMENT_FEE", "ASC", "lowest management fee"
        elif any(w in q for w in ("sharpe", "שארפ", "шарп")):
            metric, direction, label = "SHARPE_RATIO", "DESC", "highest Sharpe ratio"
        elif any(w in q for w in ("risk", "deviation", "סיכון", "סטיית", "риск")):
            metric, direction, label = "STANDARD_DEVIATION", "ASC", "lowest risk (standard deviation)"
        elif any(w in q for w in ("asset", "aum", "size", "biggest", "largest", "נכסים", "גודל", "актив")):
            metric, direction, label = "TOTAL_ASSETS", "DESC", "largest total assets"
        else:
            # default: best yield
            metric, direction, label = "AVG_ANNUAL_YIELD_TRAILING_3YRS", "DESC", "best 3-year annual yield"

        sql = (
            f'SELECT FUND_NAME, MANAGING_CORPORATION, FUND_CLASSIFICATION, '
            f'TOTAL_ASSETS, AVG_ANNUAL_MANAGEMENT_FEE, YEAR_TO_DATE_YIELD, '
            f'AVG_ANNUAL_YIELD_TRAILING_3YRS, SHARPE_RATIO, STANDARD_DEVIATION '
            f'FROM "{table}" '
            f'WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "{table}") '
            f'AND {metric} IS NOT NULL '
            f'ORDER BY {metric} {direction} '
            f'LIMIT {limit}'
        )
        return {
            "sql": sql,
            "explanation": (f"[MOCK] Offline heuristic query: top {limit} {table_label} funds by {label} "
                            f"in the latest reporting period. This deterministic fallback runs without any "
                            f"API key — connect Claude API or SDK for full natural-language understanding."),
        }


_PROVIDERS = {"api": ApiProvider, "sdk": SdkProvider, "mock": MockProvider}


def get_provider(mode, model=DEFAULT_MODEL, system_prompt="", api_key=None, max_tokens=2048) -> AIProvider:
    """Factory: build the provider for the given mode."""
    cls = _PROVIDERS.get(mode)
    if cls is None:
        raise ValueError(f"Unknown ai_mode={mode!r}. Expected one of {list(_PROVIDERS)}")
    return cls(model=model, system_prompt=system_prompt, api_key=api_key, max_tokens=max_tokens)
