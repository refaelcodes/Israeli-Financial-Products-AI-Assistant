import { useMemo } from "react";
import Chart from "react-apexcharts";
import useApiData from "hooks/useApiData";
import { useThemeContext } from "app/contexts/theme/context";
import { querySQL } from "utils/apiService";
import { baseOptions, seq } from "./palette";
import ChartCard from "./ChartCard";

// Robust: typeof()='real' drops date-string rows; range keeps plausible values.
const SQL = `
  SELECT ROUND(AVG_ANNUAL_MANAGEMENT_FEE, 3) AS fee,
         ROUND(AVG_ANNUAL_YIELD_TRAILING_3YRS, 2) AS yield3,
         FUND_NAME AS name
  FROM "Gemel"
  WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "Gemel")
    AND typeof(AVG_ANNUAL_MANAGEMENT_FEE)='real'
    AND typeof(AVG_ANNUAL_YIELD_TRAILING_3YRS)='real'
    AND AVG_ANNUAL_MANAGEMENT_FEE BETWEEN 0 AND 3
    AND AVG_ANNUAL_YIELD_TRAILING_3YRS BETWEEN -50 AND 100
`;

export default function FeeVsYield() {
  const { isDark } = useThemeContext();
  const { data, loading, error } = useApiData(() => querySQL(SQL), []);

  const { series, options } = useMemo(() => {
    const base = baseOptions(isDark);
    return {
      series: [
        {
          name: "Gemel funds",
          data: data.map((r) => ({ x: Number(r.fee), y: Number(r.yield3), name: r.name })),
        },
      ],
      options: {
        ...base,
        chart: { ...base.chart, type: "scatter", zoom: { enabled: false } },
        colors: [seq(isDark)],
        markers: { size: 5, strokeWidth: 1, strokeColors: isDark ? "#1a1a19" : "#fcfcfb", fillOpacity: 0.75 },
        dataLabels: { enabled: false },
        xaxis: {
          title: { text: "Management fee (%)", style: { fontSize: "11px", fontWeight: 500 } },
          tickAmount: 6,
          labels: { formatter: (v) => `${Number(v).toFixed(1)}%` },
          axisBorder: { show: false },
          axisTicks: { show: false },
        },
        yaxis: {
          title: { text: "3Y annual yield (%)", style: { fontSize: "11px", fontWeight: 500 } },
          labels: { formatter: (v) => `${Number(v).toFixed(0)}%` },
        },
        tooltip: {
          ...base.tooltip,
          custom: ({ seriesIndex, dataPointIndex, w }) => {
            const p = w.config.series[seriesIndex].data[dataPointIndex];
            return `<div style="padding:6px 8px;font-size:11px">
              <div style="font-weight:600" dir="auto">${p.name ?? ""}</div>
              <div>Fee: ${p.x?.toFixed(2)}% · 3Y: ${p.y?.toFixed(1)}%</div></div>`;
          },
        },
        legend: { show: false },
      },
    };
  }, [data, isDark]);

  return (
    <ChartCard
      title="Fee vs. 3Y yield"
      titleHe="דמי ניהול מול תשואה (3 שנים)"
      hint={`Gemel funds · ${data.length} funds · outliers filtered`}
      loading={loading}
      error={error}
      isEmpty={!loading && data.length === 0}
      height={320}
    >
      <Chart type="scatter" height={320} series={series} options={options} />
    </ChartCard>
  );
}
