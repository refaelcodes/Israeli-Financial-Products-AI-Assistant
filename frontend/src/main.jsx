import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

import "i18n/config";
import "simplebar-react/dist/simplebar.min.css";
import "styles/index.css";

import { AgGridProvider } from "ag-grid-react";
import { AllCommunityModule } from "ag-grid-community";

const modules = [AllCommunityModule];

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <AgGridProvider modules={modules}>
      <App />
    </AgGridProvider>
  </React.StrictMode>,
);
