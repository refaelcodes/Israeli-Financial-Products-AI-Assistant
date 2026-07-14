/**
 * Base URL for the authentication API.
 *
 * Points to the app's own Flask backend under the "/api" prefix. In dev,
 * Vite proxies "/api/*" to the Flask server (see vite.config.js); in
 * production it should be served behind the same origin or a reverse proxy.
 */

export const JWT_HOST_API = "/api";
