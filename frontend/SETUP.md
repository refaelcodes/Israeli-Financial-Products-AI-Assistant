# Setup

The full setup guide (backend + frontend, architecture, production build)
lives in the repository root: [`../SETUP.md`](../SETUP.md).

Quick start for the frontend only:

```bash
npm install
npm run dev      # http://localhost:5173
```

The dev server proxies `/api/*` to the Flask backend on `http://localhost:5000`
(see [`vite.config.js`](vite.config.js)), so start the backend first.
