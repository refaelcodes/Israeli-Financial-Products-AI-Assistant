# Frontend — Israeli Financial Products

React + Vite user interface for the Israeli financial-products research
assistant. It provides holdings exploration, fund comparison (Pensia / Gemel),
validation and reporting views, and a natural-language "Client Questions" page
that sends questions to the Flask backend, which turns them into SQL and
returns live results.

Built on React 19, React Router, Tailwind CSS, and AG Grid.

## Getting Started

```bash
npm install
npm run dev        # dev server at http://localhost:5173
```

The dev server proxies `/api/*` to the Flask backend on
`http://localhost:5000` (see [`vite.config.js`](vite.config.js)), so start the
backend first — see the root [`SETUP.md`](../SETUP.md).

## Scripts

- `npm run dev` — start the Vite dev server with HMR
- `npm run build` — production build into `dist/`
- `npm run preview` — serve the production build locally
- `npm run lint` — run ESLint

## Structure

- `src/app/pages/` — feature pages (holdings, funds, questions, reports, admin…)
- `src/app/router/` — route definitions and auth guards
- `src/utils/apiService.js` — REST client for the Flask API
- `src/app/contexts/auth/` — authentication provider (JWT via `/api/login`)

Authentication talks to the app's own Flask backend; configure it and the
database as described in the root [`SETUP.md`](../SETUP.md).
