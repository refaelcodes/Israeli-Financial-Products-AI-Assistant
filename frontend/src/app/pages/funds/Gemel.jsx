import { Page } from "components/shared/Page";
import FundGrid from "./FundGrid";
import useApiData from "hooks/useApiData";
import { getGemelFunds } from "utils/apiService";

export default function Gemel() {
  const { data, loading, error, refetch } = useApiData(getGemelFunds);

  return (
    <Page title="Gemel Funds">
      <div className="transition-content w-full px-(--margin-x) pt-5 pb-6 lg:pt-6 space-y-4">
        <div>
          <h2 className="text-xl font-medium tracking-wide text-gray-800 dark:text-dark-50">
            Gemel Funds
          </h2>
          <p className="mt-1 text-sm text-gray-500 dark:text-dark-300">
            {loading
              ? "Loading provident fund data from database..."
              : `${data.length} provident funds (latest period) — live from fund_combined_db`}
          </p>
        </div>
        <FundGrid data={data} title="gemel funds" loading={loading} error={error} onRefresh={refetch} />
      </div>
    </Page>
  );
}
