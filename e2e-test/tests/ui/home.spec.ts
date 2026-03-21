import { expect, test } from "@playwright/test";

test("workspace cards render on the home page", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("heading", { name: "One product document can drive one complete feature" })).toBeVisible();
  await expect(page.getByRole("heading", { name: "Business task intake and planning" })).toBeVisible();
  await expect(page.getByLabel("Customer request")).toBeVisible();
  await expect(page.getByText("Wire backend to frontend")).toBeVisible();
  await expect(page.getByText("Connect the Vue task board to backend task APIs")).toBeVisible();
  await expect(page.getByText("Prepare k3s test namespace")).toBeVisible();
  await expect(page.getByText("backend", { exact: true })).toBeVisible();
  await expect(page.getByText("frontend", { exact: true })).toBeVisible();
  await expect(page.getByText("database", { exact: true })).toBeVisible();
  await expect(page.getByText("e2e-test", { exact: true })).toBeVisible();
  await expect(page.getByText("infrastructure", { exact: true })).toBeVisible();
});
