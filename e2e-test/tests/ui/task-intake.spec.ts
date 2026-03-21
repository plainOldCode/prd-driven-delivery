import { expect, test } from "@playwright/test";

test("business task intake form creates a new task", async ({ page }) => {
  const suffix = Date.now();
  const customerRequest = `Customer request ${suffix}`;
  const requestedWork = `Prepare business task card ${suffix}`;

  await page.goto("/");

  await page.getByLabel("Customer request").fill(customerRequest);
  await page.getByLabel("Requested work").fill(requestedWork);
  await page.getByLabel("Delivery date").fill("2026-04-10");
  await page.getByLabel("Build estimate").fill("3 engineering days");
  await page.getByLabel("Owner").fill("Sky");
  await page.getByRole("button", { name: "Create business task" }).click();

  const createdTask = page.locator(".task-item").filter({ hasText: requestedWork }).last();

  await expect(page.getByText("Business task created.")).toBeVisible();
  await expect(createdTask.getByText(requestedWork)).toBeVisible();
  await expect(createdTask.getByText(customerRequest)).toBeVisible();
  await expect(createdTask.getByText("3 engineering days")).toBeVisible();
});
