// Import Dependencies
import { Navigate } from "react-router";

// Local Imports
import { AppLayout } from "app/layouts/AppLayout";
import { DynamicLayout } from "app/layouts/DynamicLayout";
import AuthGuard from "middleware/AuthGuard";
// ----------------------------------------------------------------------

const protectedRoutes = {
  id: "protected",
  Component: AuthGuard,
  children: [
    // The dynamic layout supports both the main layout and the sideblock.
    {
      Component: DynamicLayout,
      children: [
        {
          index: true,
          element: <Navigate to="/dashboards" />,
        },
        {
          path: "dashboards",
          children: [
            {
              index: true,
              element: <Navigate to="/dashboards/home" />,
            },
            {
              path: "home",
              lazy: async () => ({
                Component: (await import("app/pages/dashboards/home")).default,
              }),
            },
          ],
        },

        // Holdings Explorer
        {
          path: "holdings",
          lazy: async () => ({
            Component: (await import("app/pages/holdings")).default,
          }),
        },

        // Funds (Pensia / Gemel)
        {
          path: "funds",
          lazy: async () => ({
            Component: (await import("app/pages/funds")).default,
          }),
          children: [
            {
              index: true,
              element: <Navigate to="/funds/pensia" />,
            },
            {
              path: "pensia",
              lazy: async () => ({
                Component: (await import("app/pages/funds/Pensia")).default,
              }),
            },
            {
              path: "gemel",
              lazy: async () => ({
                Component: (await import("app/pages/funds/Gemel")).default,
              }),
            },
          ],
        },

        // Ingestion Runs (Kanban)
        {
          path: "ingestion",
          lazy: async () => ({
            Component: (await import("app/pages/ingestion")).default,
          }),
        },

        // Client Questions
        {
          path: "questions",
          lazy: async () => ({
            Component: (await import("app/pages/questions")).default,
          }),
        },

        // Validation / Exceptions
        {
          path: "validation",
          lazy: async () => ({
            Component: (await import("app/pages/validation")).default,
          }),
        },

        // Reports
        {
          path: "reports",
          lazy: async () => ({
            Component: (await import("app/pages/reports")).default,
          }),
          children: [
            {
              index: true,
              element: <Navigate to="/reports/quarterly" />,
            },
            {
              path: "quarterly",
              lazy: async () => ({
                Component: (await import("app/pages/reports/Quarterly")).default,
              }),
            },
            {
              path: "yoy",
              lazy: async () => ({
                Component: (await import("app/pages/reports/YoY")).default,
              }),
            },
            {
              path: "risk",
              lazy: async () => ({
                Component: (await import("app/pages/reports/Risk")).default,
              }),
            },
          ],
        },

        // Admin
        {
          path: "admin",
          lazy: async () => ({
            Component: (await import("app/pages/admin")).default,
          }),
          children: [
            {
              index: true,
              element: <Navigate to="/admin/institutions" />,
            },
            {
              path: "institutions",
              lazy: async () => ({
                Component: (await import("app/pages/admin/Institutions")).default,
              }),
            },
            {
              path: "mappings",
              lazy: async () => ({
                Component: (await import("app/pages/admin/Mappings")).default,
              }),
            },
            {
              path: "users",
              lazy: async () => ({
                Component: (await import("app/pages/admin/Users")).default,
              }),
            },
          ],
        },
      ],
    },
    // The app layout supports only the main layout. Avoid using it for other layouts.
    {
      Component: AppLayout,
      children: [
        {
          path: "settings",
          lazy: async () => ({
            Component: (await import("app/pages/settings/Layout")).default,
          }),
          children: [
            {
              index: true,
              element: <Navigate to="/settings/general" />,
            },
            {
              path: "general",
              lazy: async () => ({
                Component: (await import("app/pages/settings/sections/General"))
                  .default,
              }),
            },
            {
              path: "appearance",
              lazy: async () => ({
                Component: (
                  await import("app/pages/settings/sections/Appearance")
                ).default,
              }),
            },
          ],
        },
      ],
    },
  ],
};

export { protectedRoutes };
