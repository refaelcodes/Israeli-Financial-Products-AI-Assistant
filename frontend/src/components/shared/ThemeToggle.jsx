import { SunIcon, MoonIcon } from "@heroicons/react/24/outline";
import { Button } from "components/ui";
import { useThemeContext } from "app/contexts/theme/context";

// One-click dark/light toggle for the header. Uses the existing theme context
// (persists to localStorage, toggles the `dark` class on <html>).
export function ThemeToggle() {
  const { isDark, setThemeMode } = useThemeContext();

  return (
    <Button
      onClick={() => setThemeMode(isDark ? "light" : "dark")}
      variant="flat"
      isIcon
      className="size-9 rounded-full"
      aria-label={isDark ? "Switch to light mode" : "Switch to dark mode"}
      title={isDark ? "Light mode · מצב בהיר" : "Dark mode · מצב כהה"}
    >
      {isDark ? (
        <SunIcon className="size-6 text-gray-900 dark:text-dark-100" />
      ) : (
        <MoonIcon className="size-6 text-gray-900 dark:text-dark-100" />
      )}
    </Button>
  );
}
