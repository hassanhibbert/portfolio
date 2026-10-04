import { defineConfig } from "vite";
import injectHTML from "vite-plugin-html-inject";

export default defineConfig({
  root: "src",
  plugins: [injectHTML()],
  server: {
    open: true,
    port: 3000,
  },
});
