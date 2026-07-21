import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";

export default defineConfig({
  root: "ui",
  base: "./",
  assetsInclude: ["**/*.fnt"],
  plugins: [svelte()],
  build: {
    outDir: "../web",
    emptyOutDir: true,
    target: "es2022",
    rolldownOptions: {
      output: {
        codeSplitting: {
          groups: [
            { name: "pretext", test: /node_modules[\\/]@chenglou[\\/]pretext/ },
            { name: "motion", test: /node_modules[\\/](motion|motion-dom|motion-utils)[\\/]/ },
          ],
        },
      },
    },
  },
});
