import { useMemo } from "react";
import Chart from "react-apexcharts";
import useApiData from "hooks/useApiData";
import { useThemeContext } from "app/contexts/theme/context";
import { querySQL } from "utils/apiService";
import { baseOptions, seq, chrome } from "./palette";
import ChartCard from "./ChartCard";

// One measure (fund count) across classification categories -> single-hue bar.
const SQL = `
  SELECT FUND_CLASSIFICATION AS c, COUNT(*) AS n
  FROM "Gemel"
  WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "Gemel")
    AND FUND_CLASSIFICATION IS NOT NULL AND TRIM(FUND_CLASSIFICATION) <> ''
  GROUP BY c ORDER BY n DESC LIMIT 8
`;

const clip = (v) => (typeof v === "string" && v.length > 24 ? v.slice(0, 24) + "…" : v);

export default function FundsByClassification() {
  const { isDark } = useThemeContext();
  const { data, loading, error } = useApiData(() => querySQL(SQL), []);

  const { series, options } = useMemo(() => {
    const c = chrome(isDark);
    const base = baseOptions(isDark);
    return {
      series: [{ name: "Funds", data: data.map((r) => Number(r.n) || 0) }],
      options: {
        ...base,
        chart: { ...base.chart, type: "bar" },
        colors: [seq(isDark)],
        plotOptions: {
          bar: { horizontal: true, borderRadius: 4, borderRadiusApplication: "end", barHeight: "68%" },
        },
        dataLabels: {
          enabled: true,
          offsetX: 6,
          style: { fontSize: "11px", fontWeight: 500, colors: [c.text] },
          background: { enabled: false },
        },
        xaxis: {
          categories: data.map((r) => r.c),
          axisBorder: { show: false },
          axisTicks: { show: false },
        },
        yaxis: { labels: { maxWidth: 210, formatter: clip, style: { fontSize: "11px" } } },
        tooltip: { ...base.tooltip, y: { formatter: (v) => `${v} funds` } },
        legend: { show: false },
      },
    };
  }, [data, isDark]);

  return (
    <ChartCard
      title="Funds by classification"
      titleHe="קרנות לפי סיווג"
      hint="Gemel · latest period"
      loading={loading}
      error={error}
      isEmpty={!loading && data.length === 0}
      height={320}
    >
      <Chart type="bar" height={320} series={series} options={options} />
    </ChartCard>
  );
}
