# A NL-to-SQL-Based Research Assistant

Research assistant for Israeli financial products. The app combines a Flask API, a SQLite-backed financial dataset, and a React/Vite frontend for holdings exploration, fund comparison, validation workflows, reports, and natural-language questions.

## Project Structure

- `backend/` - Flask API and database schema helpers.
- `frontend/` - React/Vite user interface.
- `SETUP.md` - local setup guide.
- `.env.example` - safe environment variable template.

## Local Setup

1. Copy `.env.example` to `.env` or export the variables in your shell.
2. Put the local SQLite database at `backend/fund_combined_db.db`.
3. Install and run the backend:

```bash
cd backend
pip install -r requirements.txt
python fund_ai_app.py
```

4. Install and run the frontend:

```bash
cd frontend
npm install
npm run dev
```

The frontend runs on `http://localhost:5173` and proxies API calls to the backend on `http://localhost:5000`.

## Data And Secrets

API keys and account credentials are not stored in the repository. The "Client Questions" natural-language feature runs in one of three modes (`AI_MODE`): `mock` (offline, no key — the default), `api` (Anthropic Claude Messages API, needs `ANTHROPIC_API_KEY`), or `sdk` (Claude Agent SDK via a local Claude subscription). The mode and API key can also be switched from the UI.

The SQLite database is intentionally excluded from Git because it is large and may contain local data.
