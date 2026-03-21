import { expect, test } from "@playwright/test";

test("health API returns UP status", async ({ request, baseURL }) => {
  const response = await request.get(`${baseURL}/api/health`);
  const body = await response.json();

  expect(response.ok()).toBeTruthy();
  expect(body.service).toBe("example-backend");
  expect(body.workspace).toBe("example-workspace");
  expect(body.status).toBe("UP");
});
