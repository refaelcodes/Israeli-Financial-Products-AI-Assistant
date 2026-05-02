import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import jsconfigPaths from 'vite-jsconfig-paths'
import eslint from 'vite-plugin-eslint';
import svgr from 'vite-plugin-svgr'
import tailwindcss from "@tailwindcss/vite";


// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react({
    reactCompiler: false
  }), jsconfigPaths(), svgr(),
  eslint(), tailwindcss(),
  ],
  server: {
    proxy: {
      // Forward /api/* requests to Flask backend on port 5000
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
  },
})
