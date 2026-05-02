#!/usr/bin/env python3
"""
fund_ai_app.py
==============
AI-powered web application for querying the Israeli Pension & Provident Fund database.

Users ask questions in natural language (Hebrew / Russian / English),
an AI model translates them into SQL, executes against fund_combined_db.db,
and returns formatted results.

Architecture:
    Browser  ←→  Flask (this file)  ←→  AI API (Anthropic Claude)
                                     ←→  SQLite (fund_combined_db.db)

Usage:
    # Set your API key:
    export ANTHROPIC_API_KEY=<your-key>

    # Run:
    python fund_ai_app.py

    # Open: http://localhost:5000
"""

import json
import os
import re
import sqlite3
import sys
import traceback
from datetime import datetime

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════

DB_FILENAME = "fund_combined_db.db"
SCHEMA_FILENAME = "fund_combined_db_schema.sql"
APP_PORT = int(os.environ.get("FUND_AI_PORT", 5000))
APP_HOST = os.environ.get("FUND_AI_HOST", "0.0.0.0")

import os

# AI API configuration — supports Anthropic Claude, OpenAI, and Google Gemini
AI_PROVIDER = os.environ.get("AI_PROVIDER", "gemini").strip().lower()  # "anthropic" | "openai" | "gemini"

# normalize common synonyms
if AI_PROVIDER in ("google", "googleai", "google-genai", "google_generative_ai", "genai"):
    AI_PROVIDER = "gemini"

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "").strip()
OPENAI_API_KEY     = os.environ.get("OPENAI_API_KEY", "").strip()

# Gemini key: allow either GEMINI_API_KEY or GOOGLE_API_KEY (people use both)
GEMINI_API_KEY = (
    os.environ.get("GEMINI_API_KEY")
    or os.environ.get("GOOGLE_API_KEY")
    or ""
).strip()

AI_MODEL = os.environ.get("AI_MODEL", "").strip()  # auto-detected if empty

# Choose a default model if none was provided
if not AI_MODEL:
    if AI_PROVIDER == "anthropic":
        # Anthropic release notes recommend Sonnet 4.5 as a migration target. :contentReference[oaicite:0]{index=0}
        AI_MODEL = "claude-sonnet-4-5-20250929"
    elif AI_PROVIDER == "openai":
        # OpenAI docs list GPT-5.2 as a featured/frontier model. :contentReference[oaicite:1]{index=1}
        AI_MODEL = "gpt-5.2"
    elif AI_PROVIDER == "gemini":
        # Google Gemini docs show usage with a gemini-* model name (example: gemini-3-flash-preview). :contentReference[oaicite:2]{index=2}
        AI_MODEL = "gemini-3-flash-preview"
    else:
        raise ValueError(f"Unsupported AI_PROVIDER={AI_PROVIDER!r}. Use: anthropic | openai | gemini")

# ═══════════════════════════════════════════════════════════════
# DATABASE SCHEMA — compact representation for AI context
# ═══════════════════════════════════════════════════════════════

DB_SCHEMA_TEXT = """
=== FUND STATISTICS ===

TABLE "Gemel" — Israeli provident/savings funds (קופות גמל). ~2,500 funds.
  FUND_ID REAL (PK-like), FUND_NAME TEXT, FUND_CLASSIFICATION TEXT,
  CONTROLLING_CORPORATION TEXT, MANAGING_CORPORATION TEXT,
  REPORT_PERIOD REAL (YYYYMM format, e.g. 202412),
  INCEPTION_DATE TEXT, TARGET_POPULATION TEXT,
  SPECIALIZATION TEXT, SUB_SPECIALIZATION TEXT,
  DEPOSITS REAL, WITHDRAWLS REAL, INTERNAL_TRANSFERS REAL, NET_MONTHLY_DEPOSITS REAL,
  TOTAL_ASSETS REAL (in thousands ILS), AVG_ANNUAL_MANAGEMENT_FEE REAL (%),
  AVG_DEPOSIT_FEE REAL (%), MONTHLY_YIELD REAL (%), YEAR_TO_DATE_YIELD REAL (%),
  YIELD_TRAILING_3_YRS REAL, YIELD_TRAILING_5_YRS REAL,
  AVG_ANNUAL_YIELD_TRAILING_3YRS REAL (%), AVG_ANNUAL_YIELD_TRAILING_5YRS REAL (%),
  STANDARD_DEVIATION REAL, ALPHA REAL, SHARPE_RATIO REAL,
  LIQUID_ASSETS_PERCENT REAL (%), STOCK_MARKET_EXPOSURE REAL (%),
  FOREIGN_EXPOSURE REAL (%), FOREIGN_CURRENCY_EXPOSURE REAL (%),
  MANAGING_CORPORATION_LEGAL_ID REAL, CURRENT_DATE TEXT

TABLE "Pensia" — Israeli pension funds (קרנות פנסיה). ~500 funds.
  FUND_ID REAL, FUND_NAME TEXT, PARENT_COMPANY_ID REAL,
  PARENT_COMPANY_NAME TEXT, FUND_CLASSIFICATION TEXT,
  CONTROLLING_CORPORATION TEXT, MANAGING_CORPORATION TEXT,
  MANAGING_CORPORATION_LEGAL_ID REAL,
  REPORT_PERIOD REAL (YYYYMM format),
  INCEPTION_DATE TEXT, DEPOSITS REAL, WITHDRAWLS REAL,
  INTERNAL_TRANSFERS REAL, NET_MONTHLY_DEPOSITS REAL,
  TOTAL_ASSETS REAL, AVG_ANNUAL_MANAGEMENT_FEE REAL (%),
  AVG_DEPOSIT_FEE REAL (%), MONTHLY_YIELD REAL (%),
  YEAR_TO_DATE_YIELD REAL (%), ACTUARIAL_ADJUSTMENT REAL,
  YIELD_TRAILING_3_YRS REAL, YIELD_TRAILING_5_YRS REAL,
  AVG_ANNUAL_YIELD_TRAILING_3YRS REAL (%), AVG_ANNUAL_YIELD_TRAILING_5YRS REAL (%),
  STANDARD_DEVIATION REAL, ALPHA REAL, SHARPE_RATIO REAL,
  LIQUID_ASSETS_PERCENT REAL, STOCK_MARKET_EXPOSURE REAL (%),
  FOREIGN_EXPOSURE REAL (%), FOREIGN_CURRENCY_EXPOSURE REAL (%),
  CURRENT_DATE TEXT

NOTE: To get the latest period use: WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM Gemel)
NOTE: Fund classifications include: גמל להשקעה, קג"מ, קרן השתלמות, מרכזית לפיצויים, etc.
NOTE: Pensia has ACTUARIAL_ADJUSTMENT and PARENT_COMPANY columns not in Gemel.
NOTE: Gemel has TARGET_POPULATION, SPECIALIZATION, SUB_SPECIALIZATION not in Pensia.

=== ASSET HOLDINGS (29 tables) ===
All asset tables share: row_id INTEGER PK, source_file TEXT, report_date TEXT, entity_id TEXT.
entity_id in asset tables can be joined with CAST(FUND_ID AS INTEGER) from Gemel/Pensia.

Tradable securities:
  cash_equivalents — bank_name, fair_value, interest_rate, currency_code
  government_bonds — security_name, security_id, duration, maturity_date, yield_to_maturity, fair_value
  corporate_bonds — issuer_name, security_name, rating, duration, interest_rate, fair_value, industry_sector
  commercial_papers — similar to corporate_bonds
  traded_stocks — issuer_name, security_name, security_id, market_type, exposure_country, industry_sector, fair_value
  etfs — security_name, fund_classification, fair_value
  mutual_funds — security_name, fund_classification, fair_value
  warrants — security_name, exercise_price, expiry_date, fair_value
  options — security_name, exercise_price, expiry_date, fair_value
  futures — security_name, underlying_asset, fair_value
  structured_products — security_name, underlying_asset, rating, fair_value

Non-tradable (prefix nt_):
  nt_government_bonds, nt_designated_bonds, nt_commercial_papers, nt_corporate_bonds,
  nt_stocks, nt_warrants, nt_options, nt_other_derivatives, nt_structured_products

Other:
  guaranteed_return, investment_funds, loans, deposits_over_3m, real_estate,
  held_companies, other_assets, credit_facilities, investment_commitments

Metadata tables: _table_metadata, _column_metadata, _ingestion_log
"""

# ═══════════════════════════════════════════════════════════════
# AI SYSTEM PROMPT
# ═══════════════════════════════════════════════════════════════

SYSTEM_PROMPT = f"""You are an AI assistant for the Israeli Pension & Provident Fund database.
You translate natural-language questions into SQLite SQL queries.

DATABASE SCHEMA:
{DB_SCHEMA_TEXT}

RULES:
1. Output ONLY valid SQLite SQL. No markdown, no explanations before the SQL.
2. After the SQL, add a line "---" then a brief explanation of what the query does (1-3 sentences).
3. Use SELECT only — never INSERT, UPDATE, DELETE, DROP, ALTER, CREATE.
4. Always quote table names with double quotes if they start with uppercase: "Gemel", "Pensia".
5. For the latest data, use: WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "Gemel")
6. REPORT_PERIOD is numeric YYYYMM (e.g. 202412). Do NOT treat it as a date string.
7. Yield/fee columns are percentages already (e.g. 1.5 means 1.5%).
8. TOTAL_ASSETS is in thousands of ILS.
9. To combine gemel + pensia use UNION ALL with matching columns.
10. To join fund stats with assets: CAST(g.FUND_ID AS INTEGER) = CAST(a.entity_id AS INTEGER)
11. LIMIT results to 50 unless user asks for more.
12. Sort by the most relevant metric (e.g. yield DESC for "best funds").
13. The user may write in Hebrew, Russian, or English — always respond with SQL + explanation.
14. In explanations, use the same language as the user's question.
15. When user says "доходность" = yield/return, "фонд" = fund, "комиссия" = management fee.
16. Hebrew terms: תשואה = yield, נכסים = assets, דמי ניהול = management fee, סיכון = risk.
17. If the question is ambiguous, make reasonable assumptions and note them in the explanation.

RESPONSE FORMAT:
```sql
<your SQL query here>
```
---
<brief explanation in the user's language>
"""

# ═══════════════════════════════════════════════════════════════
# DATABASE HELPERS
# ═══════════════════════════════════════════════════════════════

def get_db_path():
    """Find the database file."""
    candidates = [
        os.path.join(os.path.dirname(os.path.abspath(__file__)), DB_FILENAME),
        os.path.join(os.getcwd(), DB_FILENAME),
    ]
    for c in candidates:
        if os.path.isfile(c):
            return c
    return None


def get_db_connection():
    """Get a read-only database connection."""
    db_path = get_db_path()
    if not db_path:
        raise FileNotFoundError(f"Database '{DB_FILENAME}' not found")
    conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA query_only = ON")
    return conn


def execute_query(sql, max_rows=500):
    """Execute a SELECT query and return results as list of dicts."""
    conn = get_db_connection()
    try:
        # Safety: only allow SELECT
        clean = sql.strip().upper()
        if not clean.startswith("SELECT") and not clean.startswith("WITH"):
            raise ValueError("Only SELECT queries are allowed")

        # Forbid dangerous statements
        forbidden = ["INSERT", "UPDATE", "DELETE", "DROP", "ALTER", "CREATE",
                      "ATTACH", "DETACH", "PRAGMA"]
        for word in forbidden:
            if re.search(rf'\b{word}\b', clean):
                raise ValueError(f"Forbidden operation: {word}")

        cursor = conn.execute(sql)
        columns = [desc[0] for desc in cursor.description] if cursor.description else []
        rows = cursor.fetchmany(max_rows)
        data = [dict(zip(columns, row)) for row in rows]

        # Check if there are more rows
        extra = cursor.fetchone()
        truncated = extra is not None

        return {
            "columns": columns,
            "data": data,
            "row_count": len(data),
            "truncated": truncated,
        }
    finally:
        conn.close()


def get_db_stats():
    """Return basic database statistics."""
    conn = get_db_connection()
    try:
        stats = {}
        tables = conn.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
        ).fetchall()
        stats["table_count"] = len(tables)

        for (t,) in tables:
            try:
                count = conn.execute(f'SELECT COUNT(*) FROM "{t}"').fetchone()[0]
                stats[t] = count
            except Exception:
                stats[t] = -1

        # Get report periods
        try:
            gemel_periods = conn.execute(
                'SELECT DISTINCT CAST(REPORT_PERIOD AS INTEGER) as p FROM "Gemel" ORDER BY p DESC LIMIT 5'
            ).fetchall()
            stats["gemel_periods"] = [r[0] for r in gemel_periods]
        except Exception:
            stats["gemel_periods"] = []

        try:
            pensia_periods = conn.execute(
                'SELECT DISTINCT CAST(REPORT_PERIOD AS INTEGER) as p FROM "Pensia" ORDER BY p DESC LIMIT 5'
            ).fetchall()
            stats["pensia_periods"] = [r[0] for r in pensia_periods]
        except Exception:
            stats["pensia_periods"] = []

        return stats
    finally:
        conn.close()


# ═══════════════════════════════════════════════════════════════
# AI API INTEGRATION
# ═══════════════════════════════════════════════════════════════

def call_ai_anthropic(user_message, conversation_history=None):
    """Call Anthropic Claude API."""
    import httpx

    api_key = ANTHROPIC_API_KEY
    if not api_key:
        raise ValueError("ANTHROPIC_API_KEY not set. Set it as an environment variable.")

    model = AI_MODEL or "claude-sonnet-4-20250514"

    messages = []
    if conversation_history:
        for msg in conversation_history[-6:]:  # Keep last 6 messages for context
            messages.append({"role": msg["role"], "content": msg["content"]})
    messages.append({"role": "user", "content": user_message})

    response = httpx.post(
        "https://api.anthropic.com/v1/messages",
        headers={
            "x-api-key": api_key,
            "anthropic-version": "2023-06-01",
            "content-type": "application/json",
        },
        json={
            "model": model,
            "max_tokens": 2048,
            "system": SYSTEM_PROMPT,
            "messages": messages,
        },
        timeout=60,
    )
    response.raise_for_status()
    result = response.json()
    return result["content"][0]["text"]

def call_ai_gemini(user_message, conversation_history=None):
    """Call Gemini Developer API (models.generateContent) via REST."""
    import os
    import httpx

    api_key = (
        globals().get("GEMINI_API_KEY")
        or os.getenv("GEMINI_API_KEY")
        or os.getenv("GOOGLE_API_KEY")
        or ""
    ).strip()
    if not api_key:
        raise ValueError("GEMINI_API_KEY not set. Set it as an environment variable.")

    model = globals().get("AI_MODEL") or "gemini-2.5-flash"  # default example model :contentReference[oaicite:0]{index=0}
    system_prompt = globals().get("SYSTEM_PROMPT", "")

    def _to_gemini_role(role: str):
        r = (role or "").lower()
        if r == "user":
            return "user"
        if r in ("assistant", "model"):
            return "model"
        # ignore "system" in history (we use systemInstruction below)
        return None

    # Build multi-turn "contents"
    contents = []
    if conversation_history:
        for msg in conversation_history[-6:]:
            role = _to_gemini_role(msg.get("role"))
            if not role:
                continue
            text = msg.get("content")
            if text is None:
                continue
            contents.append(
                {"role": role, "parts": [{"text": str(text)}]}
            )

    contents.append({"role": "user", "parts": [{"text": str(user_message)}]})

    payload = {
        "contents": contents,
        "generationConfig": {
            "maxOutputTokens": 2048,
            "temperature": 0.1,
        },
    }

    # System prompt / system instruction (recommended way to steer behavior) :contentReference[oaicite:1]{index=1}
    if system_prompt.strip():
        payload["systemInstruction"] = {
            "role": "system",
            "parts": [{"text": system_prompt}],
        }

    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"  # :contentReference[oaicite:2]{index=2}

    resp = httpx.post(
        url,
        headers={
            "x-goog-api-key": api_key,  # :contentReference[oaicite:3]{index=3}
            "Content-Type": "application/json",
        },
        json=payload,
        timeout=60,
    )
    resp.raise_for_status()
    data = resp.json()

    # Extract plain text from the first candidate
    try:
        parts = data["candidates"][0]["content"]["parts"]
        text_chunks = [
            p.get("text", "") for p in parts
            if isinstance(p, dict) and p.get("text")
        ]
        return "\n".join(text_chunks).strip()
    except (KeyError, IndexError, TypeError):
        # Helpful when the response is blocked or the schema changes
        raise RuntimeError(f"Unexpected Gemini response: {data}")


def call_ai_openai(user_message, conversation_history=None):
    """Call OpenAI API."""
    import httpx

    api_key = OPENAI_API_KEY
    if not api_key:
        raise ValueError("OPENAI_API_KEY not set. Set it as an environment variable.")

    model = AI_MODEL or "gpt-4o"

    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    if conversation_history:
        for msg in conversation_history[-6:]:
            messages.append({"role": msg["role"], "content": msg["content"]})
    messages.append({"role": "user", "content": user_message})

    response = httpx.post(
        "https://api.openai.com/v1/chat/completions",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        json={
            "model": model,
            "messages": messages,
            "max_tokens": 2048,
            "temperature": 0.1,
        },
        timeout=60,
    )
    response.raise_for_status()
    result = response.json()
    return result["choices"][0]["message"]["content"]


def call_ai(user_message, conversation_history=None):
    """Route to the configured AI provider."""
    if AI_PROVIDER == "openai":
        return call_ai_openai(user_message, conversation_history)
    else:
        return call_ai_gemini(user_message, conversation_history)


def parse_ai_response(response_text):
    """Parse AI response to extract SQL and explanation."""
    sql = ""
    explanation = ""

    # Try to extract SQL from code blocks
    sql_match = re.search(r'```sql\s*(.*?)\s*```', response_text, re.DOTALL)
    if sql_match:
        sql = sql_match.group(1).strip()
    else:
        # Try to find SQL without code blocks (before ---)
        parts = response_text.split("---", 1)
        if len(parts) == 2:
            sql = parts[0].strip()
            if sql.startswith("```"):
                sql = sql.strip("`").strip()
        else:
            # Attempt to extract any SELECT statement
            select_match = re.search(
                r'((?:WITH|SELECT)\s+.*?;)',
                response_text,
                re.DOTALL | re.IGNORECASE,
            )
            if select_match:
                sql = select_match.group(1).strip()

    # Extract explanation
    if "---" in response_text:
        explanation = response_text.split("---", 1)[1].strip()
    elif sql:
        # Everything after the SQL block
        after_sql = response_text.split(sql)[-1].strip()
        after_sql = re.sub(r'^```\s*', '', after_sql).strip()
        if after_sql:
            explanation = after_sql

    # Clean up SQL
    sql = sql.strip().rstrip(";") + ";" if sql.strip() else ""

    return sql, explanation


# ═══════════════════════════════════════════════════════════════
# FLASK APPLICATION
# ═══════════════════════════════════════════════════════════════

app = Flask(__name__, static_folder="static")
CORS(app)  # Allow React dev server (Vite on :5173) to call Flask API


@app.route("/")
def index():
    """Serve the main HTML page."""
    return send_from_directory(
        os.path.dirname(os.path.abspath(__file__)), "fund_ai_frontend.html"
    )


@app.route("/api/ask", methods=["POST"])
def api_ask():
    """Main AI endpoint: receive a question, return SQL + results."""
    try:
        body = request.json or {}
        question = body.get("question", "").strip()
        history = body.get("history", [])

        if not question:
            return jsonify({"error": "Empty question"}), 400

        # Step 1: Call AI to generate SQL
        ai_response = call_ai(question, history)
        sql, explanation = parse_ai_response(ai_response)

        if not sql:
            return jsonify({
                "question": question,
                "ai_raw": ai_response,
                "sql": "",
                "explanation": explanation or ai_response,
                "data": None,
                "error": "Could not extract SQL from AI response",
            })

        # Step 2: Execute SQL
        try:
            result = execute_query(sql)
            return jsonify({
                "question": question,
                "sql": sql,
                "explanation": explanation,
                "columns": result["columns"],
                "data": result["data"],
                "row_count": result["row_count"],
                "truncated": result["truncated"],
                "error": None,
            })
        except Exception as db_err:
            return jsonify({
                "question": question,
                "sql": sql,
                "explanation": explanation,
                "data": None,
                "error": f"SQL execution error: {str(db_err)}",
                "ai_raw": ai_response,
            })

    except ValueError as ve:
        return jsonify({"error": str(ve)}), 400
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": f"Server error: {str(e)}"}), 500


@app.route("/api/query", methods=["POST"])
def api_query():
    """Direct SQL execution endpoint (for advanced users)."""
    try:
        body = request.json or {}
        sql = body.get("sql", "").strip()
        if not sql:
            return jsonify({"error": "Empty SQL"}), 400
        result = execute_query(sql)
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/api/stats")
def api_stats():
    """Return database statistics."""
    try:
        stats = get_db_stats()
        return jsonify(stats)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/schema")
def api_schema():
    """Return the schema description."""
    return jsonify({"schema": DB_SCHEMA_TEXT})


@app.route("/api/health")
def api_health():
    """Health check."""
    db_ok = get_db_path() is not None
    ai_ok = bool(ANTHROPIC_API_KEY or OPENAI_API_KEY or GEMINI_API_KEY)
    return jsonify({
        "status": "ok" if (db_ok and ai_ok) else "degraded",
        "database": "connected" if db_ok else "missing",
        "ai_provider": AI_PROVIDER,
        "ai_configured": ai_ok,
        "db_path": get_db_path(),
    })


# ═══════════════════════════════════════════════════════════════
# ENTRY POINT
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("  Fund AI — Natural Language Database Explorer")
    print("=" * 60)

    db = get_db_path()
    if db:
        print(f"  Database : {db}")
    else:
        print(f"  WARNING  : '{DB_FILENAME}' not found!")
        print(f"             Run fund_combined_gui.py to create it,")
        print(f"             or place it next to this script.")

    if ANTHROPIC_API_KEY:
        print(f"  AI       : Anthropic ({AI_MODEL or 'claude-sonnet-4-20250514'})")
    elif AI_PROVIDER == "gemini":
        if GEMINI_API_KEY:
            print(f"  AI       : Google Gemini ({AI_MODEL or 'gemini-3-flash-preview'})")
        else:
            print(f"  WARNING  : No Gemini API key set!")
            print(f"             export GEMINI_API_KEY=<your-key>")
    elif OPENAI_API_KEY:
        print(f"  AI       : OpenAI ({AI_MODEL or 'gpt-4o'})")
    else:
        print(f"  WARNING  : No AI API key set!")
        print(f"             export ANTHROPIC_API_KEY=<your-key>")
        print(f"             export OPENAI_API_KEY=sk-...")

    print(f"  Server   : http://{APP_HOST}:{APP_PORT}")
    print("=" * 60)

    app.run(host=APP_HOST, port=APP_PORT, debug=True)
