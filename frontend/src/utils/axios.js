import axios from 'axios';

import { JWT_HOST_API } from 'configs/auth.config';


const axiosInstance = axios.create({
  baseURL: JWT_HOST_API,
});

axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    // Always reject with an object exposing a readable `.message`, so callers
    // (and the auth UI) never end up showing an empty error.
    const data = error.response?.data;
    const status = error.response?.status;
    let message;
    if (data && typeof data === 'object' && data.message) {
      message = data.message;
    } else if (status >= 500) {
      // Vite dev proxy returns 5xx when it can't reach the Flask backend.
      message = `Request failed (${status}) — is the backend running on :5000?`;
    } else if (status) {
      message = `Request failed (${status})`;
    } else {
      message = error.message || 'Network error — is the backend running?';
    }
    return Promise.reject({ message });
  }
);

export default axiosInstance;
