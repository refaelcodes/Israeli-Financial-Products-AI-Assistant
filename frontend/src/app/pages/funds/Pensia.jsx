import { Page } from "components/shared/Page";
import FundGrid from "./FundGrid";
import useApiData from "hooks/useApiData";
import { getPensiaFunds } from "utils/apiService";

export default function Pensia() {
  const { data, loading, error, refetch } = useApiData(getPensiaFunds);

  return (
    <Page title="Pensia Funds">
      <div className="transition-content w-full px-(--margin-x) pt-5 pb-6 lg:pt-6 space-y-4">
        <div>
          <h2 className="text-xl font-medium tracking-wide text-gray-800 dark:text-dark-50">
            Pensia Funds
          </h2>
          <p className="mt-1 text-sm text-gray-500 dark:text-dark-300">
            {loading
              ? "Loading pension fund data from database..."
              : `${data.length} pension funds (latest period) — live from fund_combined_db`}
          </p>
        </div>
        <FundGrid data={data} title="pensia funds" loading={loading} error={error} onRefresh={refetch} />
      </div>
    </Page>
  );
}
