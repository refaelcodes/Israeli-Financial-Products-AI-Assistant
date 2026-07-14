# Fund Explorer - Setup Guide

## Prerequisites
- **Node.js** 18+ (https://nodejs.org)
- **Python** 3.10+ (https://python.org)

## Quick Start (2 terminals)

### Terminal 1 — Backend (Flask API + SQLite)
```bash
cd backend
pip install -r requirements.txt
python fund_ai_app.py
```
Server starts at **http://localhost:5000**

### Terminal 2 — Frontend (React + Vite)
```bash
cd frontend
npm install
npm run dev
```
App opens at **http://localhost:5173**

## What You Get
| Tab | Data Source |
|-----|------------|
| Holdings Explorer | 29 asset tables (stocks, bonds, ETFs...) |
| Funds > Pensia | ~500 pension funds from "Pensia" table |
| Funds > Gemel | ~2500 provident funds from "Gemel" table |
| Client Questions | AI-powered: type question -> SQL -> live results |
| Ingestion Runs | Kanban workflow board |
| Validation | Data quality exceptions |
| Reports | Quarterly / YoY / Risk |
| Admin | Institutions / Mappings / Users |

## Architecture
```
Browser (localhost:5173)
    |  /api/*
Vite Dev Proxy
    |
Flask API (localhost:5000)
    |
SQLite DB (fund_combined_db.db, 160MB, 34 tables)
    |
Claude — API / Agent SDK / Mock (for natural language queries)
```

## Authentication

The app uses real JWT authentication served by the Flask backend. Users are
stored (with hashed passwords) in a separate `backend/auth.db`, which is
created automatically on first run and is **not** committed to Git.

On first startup, if no users exist, a seed user is created from environment
variables:

| Variable | Purpose | Default |
|----------|---------|---------|
| `AUTH_DEFAULT_USERNAME` | Seed login username | `admin` |
| `AUTH_DEFAULT_PASSWORD` | Seed login password | `admin123` (set your own!) |
| `JWT_SECRET` | Secret used to sign tokens | random per run (set for persistence) |

Set these in `.env` before the first run, then sign in with those credentials.
New users can also self-register from the app's **Create account** page
(backed by `POST /api/register`).

## AI Modes (Client Questions)

The natural-language "Client Questions" page turns a question into SQL and runs
it on the database. Pick the provider with `AI_MODE` (or switch it live in the
UI panel on that page):

| `AI_MODE` | What it does | Needs |
|-----------|--------------|-------|
| `mock` (default) | Offline, deterministic SQL from keyword heuristics — runs against the real DB with **no key** | nothing |
| `api` | Anthropic Claude **Messages API** (forced structured `run_sql_query` tool call) | `ANTHROPIC_API_KEY` (env or UI) |
| `sdk` | **Claude Agent SDK** via your local `claude` login | `claude-agent-sdk` package + `claude` auth |

`api`/`sdk` default to `claude-opus-4-8` (also `claude-sonnet-5`, `claude-haiku-4-5`,
`claude-fable-5`). Keys entered in the UI stay in memory unless you tick
"Remember", which writes them to a git-ignored `backend/.local_credentials.json`.

## Production Build
```bash
cd frontend
npm run build
npm run preview   # serves from dist/ folder
```
