import { expect, test } from "@playwright/test";

test("health API returns UP status", async ({ request, baseURL }) => {
  const response = await request.get(`${baseURL}/api/health`);
  const body = await response.json();

  expect(response.ok()).toBeTruthy();
  expect(body.service).toBe("prd-delivery-backend");
  expect(body.workspace).toBe("prd-driven-delivery");
  expect(body.status).toBe("UP");
});
