import { expect, test } from "@playwright/test";

test("workspace cards render on the home page", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("heading", { name: "A minimal foundation for a multi-project development workspace" })).toBeVisible();
  await expect(page.getByText("backend")).toBeVisible();
  await expect(page.getByText("frontend")).toBeVisible();
  await expect(page.getByText("database")).toBeVisible();
  await expect(page.getByText("e2e-test")).toBeVisible();
  await expect(page.getByText("infrastructure")).toBeVisible();
});
