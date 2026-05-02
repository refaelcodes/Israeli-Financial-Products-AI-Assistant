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
| Holdings Explorer | 27 asset tables (stocks, bonds, ETFs...) |
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
SQLite DB (fund_combined_db.db, 160MB, 32 tables)
    |
Google Gemini AI (for natural language queries)
```

## Production Build
```bash
cd frontend
npm run build
npm run preview   # serves from dist/ folder
```
