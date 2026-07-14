import { useMemo } from "react";
import Chart from "react-apexcharts";
import useApiData from "hooks/useApiData";
import { useThemeContext } from "app/contexts/theme/context";
import { querySQL } from "utils/apiService";
import { baseOptions, cat } from "./palette";
import ChartCard from "./ChartCard";

// Sum fair_value across the main tradable asset tables. Categorical identity
// (asset class) -> fixed-order categorical palette + legend + % labels, so
// identity is never carried by color alone.
const SQL = `
  SELECT class, ROUND(v/1e6, 2) AS aum FROM (
    SELECT 'Stocks' AS class, SUM(fair_value) v FROM traded_stocks
    UNION ALL SELECT 'Gov bonds',   SUM(fair_value) FROM government_bonds
    UNION ALL SELECT 'Corp bonds',  SUM(fair_value) FROM corporate_bonds
    UNION ALL SELECT 'ETFs',        SUM(fair_value) FROM etfs
    UNION ALL SELECT 'Mutual funds',SUM(fair_value) FROM mutual_funds
    UNION ALL SELECT 'Commercial papers', SUM(fair_value) FROM commercial_papers
  )
  WHERE v IS NOT NULL AND v > 0
  ORDER BY aum DESC
`;

// EN label -> Hebrew, for the legend.
const HE = {
  Stocks: "מניות",
  "Gov bonds": 'אג"ח ממשלתי',
  "Corp bonds": 'אג"ח קונצרני',
  ETFs: "תעודות סל",
  "Mutual funds": "קרנות נאמנות",
  "Commercial papers": "ניירות מסחריים",
};

export default function AssetAllocation() {
  const { isDark } = useThemeContext();
  const { data, loading, error } = useApiData(() => querySQL(SQL), []);

  const { series, options } = useMemo(() => {
    const base = baseOptions(isDark);
    return {
      series: data.map((r) => Number(r.aum) || 0),
      options: {
        ...base,
        chart: { ...base.chart, type: "donut" },
        colors: cat(isDark),
        labels: data.map((r) => `${r.class} · ${HE[r.class] || ""}`),
        stroke: { width: 2, colors: [isDark ? "#1a1a19" : "#fcfcfb"] }, // 2px surface gap
        dataLabels: {
          enabled: true,
          formatter: (val) => `${Number(val).toFixed(0)}%`,
          style: { fontSize: "11px", fontWeight: 600 },
          dropShadow: { enabled: false },
        },
        legend: { position: "bottom", fontSize: "11px", markers: { width: 10, height: 10 } },
        plotOptions: {
          pie: { donut: { size: "62%", labels: { show: true, total: { show: true, label: "Total ₪B", formatter: (w) => `₪${w.globals.seriesTotals.reduce((a, b) => a + b, 0).toFixed(0)}B` } } } },
        },
        tooltip: { ...base.tooltip, y: { formatter: (v) => `₪${Number(v).toFixed(2)}B` } },
      },
    };
  }, [data, isDark]);

  return (
    <ChartCard
      title="Asset allocation"
      titleHe="פילוח נכסים לפי סוג"
      hint="Fair value across holdings tables (₪B)"
      loading={loading}
      error={error}
      isEmpty={!loading && data.length === 0}
      height={320}
    >
      <Chart type="donut" height={320} series={series} options={options} />
    </ChartCard>
  );
}
