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

from flask import Flask, request, jsonify, send_from_directory, g
from flask_cors import CORS

import auth
import ai_provider

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════

DB_FILENAME = "fund_combined_db.db"
SCHEMA_FILENAME = "fund_combined_db_schema.sql"
APP_PORT = int(os.environ.get("FUND_AI_PORT", 5000))
APP_HOST = os.environ.get("FUND_AI_HOST", "0.0.0.0")

# AI mode for "Client Questions" (NL -> SQL). One of: mock | api | sdk
#   mock — offline, deterministic heuristic SQL (default; no key needed)
#   api  — Anthropic Messages API (needs ANTHROPIC_API_KEY; billed)
#   sdk  — Claude Agent SDK via a local Claude subscription
AI_MODE = os.environ.get("AI_MODE", "mock").strip().lower()
if AI_MODE not in ai_provider.VALID_MODES:
    AI_MODE = "mock"
AI_MODEL = os.environ.get("AI_MODEL", "").strip() or ai_provider.DEFAULT_MODEL

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

# The NL->SQL system prompt is composed from the schema inside ai_provider,
# so every provider mode (api/sdk/mock) shares one contract.
SYSTEM_PROMPT = ai_provider.build_system_prompt(DB_SCHEMA_TEXT)

# ═══════════════════════════════════════════════════════════════
# AI PROVIDER STATE (mode switch + connection, mirrors the Client Questions UI)
# ═══════════════════════════════════════════════════════════════
# Active mode/model plus connection secrets live only in memory, and are
# persisted to a git-ignored file ONLY when the user asks to "remember".
_CREDS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".local_credentials.json")
_AI_RUNTIME = {"ai_mode": AI_MODE, "model": AI_MODEL, "api_key": None, "sdk": False}


def _read_saved_creds():
    try:
        with open(_CREDS_PATH, "r", encoding="utf-8") as f:
            return json.load(f) or {}
    except (FileNotFoundError, ValueError):
        return {}


def _write_saved_creds(d):
    d = {k: v for k, v in d.items() if v}  # never persist empty/False
    try:
        if d:
            with open(_CREDS_PATH, "w", encoding="utf-8") as f:
                json.dump(d, f)
        elif os.path.isfile(_CREDS_PATH):
            os.remove(_CREDS_PATH)
    except OSError:
        pass


def _load_ai_state():
    """Restore remembered mode/model/connection on startup."""
    saved = _read_saved_creds()
    if saved.get("ai_mode") in ai_provider.VALID_MODES:
        _AI_RUNTIME["ai_mode"] = saved["ai_mode"]
    if saved.get("model") in ai_provider.VALID_MODELS:
        _AI_RUNTIME["model"] = saved["model"]
    _AI_RUNTIME["api_key"] = saved.get("api_key") or None
    _AI_RUNTIME["sdk"] = bool(saved.get("sdk"))


def _ai_connected(mode):
    """mock — always; api — key present (UI or env); sdk — confirmed."""
    if mode == "mock":
        return True
    if mode == "api":
        return bool(_AI_RUNTIME["api_key"] or os.environ.get("ANTHROPIC_API_KEY", "").strip())
    if mode == "sdk":
        return bool(_AI_RUNTIME["sdk"])
    return False


_load_ai_state()

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

def generate_sql(question, conversation_history=None):
    """Turn a natural-language question into (sql, explanation) via the active provider."""
    provider = ai_provider.get_provider(
        mode=_AI_RUNTIME["ai_mode"],
        model=_AI_RUNTIME["model"],
        system_prompt=SYSTEM_PROMPT,
        api_key=_AI_RUNTIME["api_key"],
    )
    result = provider.ask(question, conversation_history)
    sql = (result.get("sql") or "").strip()
    if sql:
        sql = sql.rstrip(";") + ";"
    return sql, (result.get("explanation") or "").strip()


# ═══════════════════════════════════════════════════════════════
# FLASK APPLICATION
# ═══════════════════════════════════════════════════════════════

app = Flask(__name__, static_folder="static")

# Restrict CORS to configured origins (default: Vite dev server on :5173).
# Set CORS_ORIGINS as a comma-separated list, or "*" to allow all.
_cors_origins_raw = os.environ.get("CORS_ORIGINS", "http://localhost:5173").strip()
if _cors_origins_raw == "*":
    CORS(app)
else:
    _origins = [o.strip() for o in _cors_origins_raw.split(",") if o.strip()]
    CORS(app, resources={r"/api/*": {"origins": _origins}})

# Initialize the authentication database (creates auth.db + seeds a user).
_auth_status = auth.init_auth_db()


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

        # Step 1: Generate SQL via the active provider (mock / api / sdk)
        try:
            sql, explanation = generate_sql(question, history)
        except Exception as ai_err:
            traceback.print_exc()
            return jsonify({
                "question": question,
                "sql": "",
                "explanation": None,
                "data": None,
                "error": f"AI error ({_AI_RUNTIME['ai_mode']}): {str(ai_err)}",
            })

        if not sql:
            return jsonify({
                "question": question,
                "sql": "",
                "explanation": explanation,
                "data": None,
                "error": "The AI did not return an SQL query.",
            })

        # Step 2: Execute SQL
        try:
            result = execute_query(sql)
            return jsonify({
                "question": question,
                "sql": sql,
                "explanation": explanation,
                "ai_mode": _AI_RUNTIME["ai_mode"],
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
            })

    except ValueError as ve:
        return jsonify({"error": str(ve)}), 400
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": f"Server error: {str(e)}"}), 500


# ═══════════════════════════════════════════════════════════════
# AI PROVIDER ENDPOINTS (mode switch + connection for Client Questions)
# ═══════════════════════════════════════════════════════════════

@app.route("/api/ai/config", methods=["GET"])
def api_ai_config():
    """Return the current AI mode/model and connection status."""
    mode = _AI_RUNTIME["ai_mode"]
    return jsonify({
        "ai_mode": mode,
        "model": _AI_RUNTIME["model"],
        "valid_modes": list(ai_provider.VALID_MODES),
        "valid_models": ai_provider.VALID_MODELS,
        "connected": _ai_connected(mode),
    })


@app.route("/api/ai/config", methods=["POST"])
def api_set_ai_config():
    """Set the active AI mode and/or model (persisted locally, git-ignored)."""
    body = request.json or {}
    if "ai_mode" in body:
        mode = str(body["ai_mode"]).strip().lower()
        if mode not in ai_provider.VALID_MODES:
            return jsonify({"error": f"Invalid ai_mode. Use: {list(ai_provider.VALID_MODES)}"}), 400
        _AI_RUNTIME["ai_mode"] = mode
    if "model" in body:
        model = str(body["model"]).strip()
        if model not in ai_provider.VALID_MODELS:
            return jsonify({"error": f"Invalid model. Use: {ai_provider.VALID_MODELS}"}), 400
        _AI_RUNTIME["model"] = model

    saved = _read_saved_creds()
    saved["ai_mode"] = _AI_RUNTIME["ai_mode"]
    saved["model"] = _AI_RUNTIME["model"]
    _write_saved_creds(saved)

    return jsonify({
        "ok": True,
        "ai_mode": _AI_RUNTIME["ai_mode"],
        "model": _AI_RUNTIME["model"],
        "connected": _ai_connected(_AI_RUNTIME["ai_mode"]),
    })


@app.route("/api/ai/connect", methods=["POST"])
def api_ai_connect():
    """Connect a mode: api needs an Anthropic key; sdk confirms local Claude auth.

    Secrets are persisted to disk ONLY when remember=true (git-ignored file);
    otherwise they live in process memory and are forgotten on restart.
    """
    body = request.json or {}
    mode = str(body.get("mode", "")).strip().lower()
    if mode not in ("api", "sdk"):
        return jsonify({"error": "mode must be 'api' or 'sdk'"}), 400

    remember = bool(body.get("remember"))
    saved = _read_saved_creds()

    if mode == "api":
        key = (body.get("api_key") or "").strip() or None
        if not key:
            return jsonify({"error": "api_key is required for API mode"}), 400
        _AI_RUNTIME["api_key"] = key
        if remember:
            saved["api_key"] = key
        else:
            saved.pop("api_key", None)
    else:  # sdk
        _AI_RUNTIME["sdk"] = True
        if remember:
            saved["sdk"] = True
        else:
            saved.pop("sdk", None)

    # Make the connected mode active.
    _AI_RUNTIME["ai_mode"] = mode
    saved["ai_mode"] = mode
    _write_saved_creds(saved)

    return jsonify({"ok": True, "ai_mode": mode, "connected": True, "remembered": remember})


@app.route("/api/ai/disconnect", methods=["POST"])
def api_ai_disconnect():
    """Forget a mode's connection (memory + disk). The active mode is unchanged."""
    body = request.json or {}
    mode = str(body.get("mode") or _AI_RUNTIME["ai_mode"]).strip().lower()
    saved = _read_saved_creds()
    if mode == "api":
        _AI_RUNTIME["api_key"] = None
        saved.pop("api_key", None)
    elif mode == "sdk":
        _AI_RUNTIME["sdk"] = False
        saved.pop("sdk", None)
    _write_saved_creds(saved)
    return jsonify({"ok": True, "ai_mode": mode, "connected": _ai_connected(mode)})


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


# ═══════════════════════════════════════════════════════════════
# AUTHENTICATION ENDPOINTS
# ═══════════════════════════════════════════════════════════════

@app.route("/api/login", methods=["POST"])
def api_login():
    """Authenticate a user and return a JWT + user profile."""
    body = request.json or {}
    username = body.get("username", "")
    password = body.get("password", "")

    user = auth.authenticate(username, password)
    if user is None:
        return jsonify({"message": "Invalid username or password"}), 401

    return jsonify({"authToken": auth.issue_token(user), "user": user})


@app.route("/api/register", methods=["POST"])
def api_register():
    """Create a new user and return a JWT + user profile.

    Not surfaced in the current UI, but kept for future self-service sign-up.
    """
    body = request.json or {}
    try:
        user = auth.create_user(
            username=body.get("username", ""),
            password=body.get("password", ""),
            email=body.get("email"),
            name=body.get("name"),
        )
    except ValueError as ve:
        return jsonify({"message": str(ve)}), 400

    return jsonify({"authToken": auth.issue_token(user), "user": user})


@app.route("/api/user/profile")
@auth.require_auth
def api_user_profile():
    """Return the profile of the currently authenticated user."""
    return jsonify({"user": g.current_user})


@app.route("/api/health")
def api_health():
    """Health check."""
    db_ok = get_db_path() is not None
    mode = _AI_RUNTIME["ai_mode"]
    ai_ok = _ai_connected(mode)
    return jsonify({
        "status": "ok" if (db_ok and ai_ok) else "degraded",
        "database": "connected" if db_ok else "missing",
        "ai_mode": mode,
        "ai_model": _AI_RUNTIME["model"],
        "ai_connected": ai_ok,
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

    _mode = _AI_RUNTIME["ai_mode"]
    _connected = "connected" if _ai_connected(_mode) else "not connected"
    print(f"  AI       : mode={_mode} model={_AI_RUNTIME['model']} ({_connected})")
    if _mode == "mock":
        print(f"             MOCK is offline/deterministic — switch to api or sdk in the UI for full NL->SQL.")
    elif _mode == "api" and not _ai_connected("api"):
        print(f"             Set ANTHROPIC_API_KEY or connect a key in the Client Questions UI.")

    if _auth_status.get("seeded"):
        print(f"  Auth     : seeded default user in {_auth_status['db_path']}")
    else:
        print(f"  Auth     : {_auth_status.get('users', 0)} user(s) in auth.db")

    print(f"  Server   : http://{APP_HOST}:{APP_PORT}")
    print("=" * 60)

    debug_mode = os.environ.get("FLASK_DEBUG", "false").strip().lower() in (
        "1", "true", "yes", "on"
    )
    app.run(host=APP_HOST, port=APP_PORT, debug=debug_mode)
