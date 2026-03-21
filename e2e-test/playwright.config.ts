import { defineConfig } from "@playwright/test";

const frontendBaseUrl = process.env.E2E_FRONTEND_BASE_URL ?? "http://127.0.0.1:5173";
const apiBaseUrl = process.env.E2E_API_BASE_URL ?? "http://127.0.0.1:8080";

export default defineConfig({
  testDir: "./tests",
  timeout: 30_000,
  fullyParallel: true,
  reporter: "list",
  use: {
    trace: "on-first-retry",
  },
  projects: [
    {
      name: "ui-smoke",
      testMatch: /ui\/.*\.spec\.ts/,
      use: {
        baseURL: frontendBaseUrl,
      },
    },
    {
      name: "api-smoke",
      testMatch: /smoke\/.*\.spec\.ts/,
      use: {
        baseURL: apiBaseUrl,
      },
    },
  ],
});
