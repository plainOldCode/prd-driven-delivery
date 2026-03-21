import { expect, test } from "@playwright/test";

test("tasks API returns seeded rows", async ({ request, baseURL }) => {
  const response = await request.get(`${baseURL}/api/tasks`);
  const body = await response.json();

  expect(response.ok()).toBeTruthy();
  expect(Array.isArray(body)).toBeTruthy();
  expect(body.length).toBeGreaterThan(0);
  expect(body[0].title).toBe("Wire backend to frontend");
});
