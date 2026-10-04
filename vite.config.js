import { defineConfig } from "vite";
import injectHTML from "vite-plugin-html-inject";

export default defineConfig({
  root: "src",
  plugins: [injectHTML()],
  build: {
    // root is src/, so put the build at the project root instead of src/dist
    outDir: "../dist",
    emptyOutDir: true,
  },
  server: {
    open: true,
    port: 3000,
  },
});
