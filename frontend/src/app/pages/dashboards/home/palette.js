// Data-viz palette — validated with the dataviz skill's validate_palette.js
// (light: all checks pass, contrast WARN on aqua/yellow/magenta -> we ship
// direct labels + legend; dark: CVD 10.3 floor band -> direct labels/gaps).
// Categorical hues are assigned in FIXED order, never cycled.

export const CAT = {
  light: ["#2a78d6", "#1baf7a", "#eda100", "#008300", "#4a3aa7", "#e34948", "#e87ba4", "#eb6834"],
  dark: ["#3987e5", "#199e70", "#c98500", "#008300", "#9085e9", "#e66767", "#d55181", "#d95926"],
};

// Single sequential hue (blue) for one-measure magnitude bars.
export const SEQ = { light: "#2a78d6", dark: "#3987e5" };

// Chart chrome (axis/grid/label ink) per mode.
export const CHROME = {
  light: { muted: "#898781", grid: "#e1e0d9", text: "#52514e" },
  dark: { muted: "#898781", grid: "#2c2c2a", text: "#c3c2b7" },
};

export const cat = (isDark) => (isDark ? CAT.dark : CAT.light);
export const seq = (isDark) => (isDark ? SEQ.dark : SEQ.light);
export const chrome = (isDark) => (isDark ? CHROME.dark : CHROME.light);

// Shared base options so every chart reads from the same tokens.
export function baseOptions(isDark) {
  const c = chrome(isDark);
  return {
    chart: {
      fontFamily: "inherit",
      foreColor: c.muted,
      toolbar: { show: false },
      animations: { speed: 300 },
      background: "transparent",
    },
    theme: { mode: isDark ? "dark" : "light" },
    grid: { borderColor: c.grid, strokeDashArray: 0 },
    tooltip: { theme: isDark ? "dark" : "light" },
    states: { active: { filter: { type: "none" } } },
  };
}
