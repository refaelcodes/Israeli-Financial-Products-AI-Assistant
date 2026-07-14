import { useMemo } from "react";
import Chart from "react-apexcharts";
import useApiData from "hooks/useApiData";
import { useThemeContext } from "app/contexts/theme/context";
import { querySQL } from "utils/apiService";
import { baseOptions, seq, chrome } from "./palette";
import ChartCard from "./ChartCard";

const SQL = `
  SELECT m, ROUND(SUM(TOTAL_ASSETS)/1e6, 2) AS aum
  FROM (
    SELECT MANAGING_CORPORATION AS m, TOTAL_ASSETS FROM "Gemel"
      WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "Gemel")
    UNION ALL
    SELECT MANAGING_CORPORATION AS m, TOTAL_ASSETS FROM "Pensia"
      WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "Pensia")
  )
  WHERE m IS NOT NULL AND TOTAL_ASSETS IS NOT NULL
  GROUP BY m ORDER BY aum DESC LIMIT 8
`;

const clip = (v) => (typeof v === "string" && v.length > 22 ? v.slice(0, 22) + "…" : v);

export default function AumByManager() {
  const { isDark } = useThemeContext();
  const { data, loading, error } = useApiData(() => querySQL(SQL), []);

  const { series, options } = useMemo(() => {
    const c = chrome(isDark);
    const base = baseOptions(isDark);
    return {
      series: [{ name: "AUM (₪B)", data: data.map((r) => Number(r.aum) || 0) }],
      options: {
        ...base,
        chart: { ...base.chart, type: "bar" },
        colors: [seq(isDark)],
        plotOptions: {
          bar: { horizontal: true, borderRadius: 4, borderRadiusApplication: "end", barHeight: "68%" },
        },
        dataLabels: {
          enabled: true,
          formatter: (v) => `₪${Number(v).toFixed(1)}B`,
          offsetX: 6,
          style: { fontSize: "11px", fontWeight: 500, colors: [c.text] },
          background: { enabled: false },
        },
        xaxis: {
          categories: data.map((r) => r.m),
          labels: { formatter: (v) => `₪${v}B` },
          axisBorder: { show: false },
          axisTicks: { show: false },
        },
        yaxis: { labels: { maxWidth: 200, formatter: clip, style: { fontSize: "11px" } } },
        tooltip: { ...base.tooltip, y: { formatter: (v) => `₪${Number(v).toFixed(2)}B` } },
        legend: { show: false },
      },
    };
  }, [data, isDark]);

  return (
    <ChartCard
      title="AUM by manager"
      titleHe="נכסים מנוהלים לפי בית השקעות"
      hint="Top 8 managing corporations · latest period"
      loading={loading}
      error={error}
      isEmpty={!loading && data.length === 0}
      height={320}
    >
      <Chart type="bar" height={320} series={series} options={options} />
    </ChartCard>
  );
}
