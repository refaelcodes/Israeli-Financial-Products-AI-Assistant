import { useState, useEffect, useCallback } from "react";

/**
 * Generic hook for fetching data from the Flask API.
 * Returns { data, loading, error, refetch }.
 *
 * @param {Function} fetchFn  - async function that returns API response
 * @param {Array}    deps     - dependency array (refetch when deps change)
 */
export default function useApiData(fetchFn, deps = []) {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const refetch = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await fetchFn();
      // API returns { columns, data, row_count, truncated }
      setData(result.data || []);
    } catch (err) {
      setError(err.message || "Failed to fetch data");
      // Keep existing data on error so grids don't flash empty
    } finally {
      setLoading(false);
    }
  }, deps); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    refetch();
  }, [refetch]);

  return { data, loading, error, refetch };
}
