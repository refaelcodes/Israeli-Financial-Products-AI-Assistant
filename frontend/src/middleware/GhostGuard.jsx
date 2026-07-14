// Import Dependencies
import { Navigate, useOutlet } from "react-router";

// Local Imports
import { useAuthContext } from "app/contexts/auth/context";
import { HOME_PATH, REDIRECT_URL_KEY } from "constants/app.constant";

// ----------------------------------------------------------------------


export default function GhostGuard() {
  const outlet = useOutlet();
  const { isAuthenticated } = useAuthContext();

  // getlist returns null when the "redirect" param is absent — guard against
  // it so we don't navigate to the literal string "null".
  const redirectUrl = new URLSearchParams(window.location.search).get(
    REDIRECT_URL_KEY,
  );

  if (isAuthenticated) {
    return <Navigate to={redirectUrl || HOME_PATH} replace />;
  }

  return <>{outlet}</>;
}
