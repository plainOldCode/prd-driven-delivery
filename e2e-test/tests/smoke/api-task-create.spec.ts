import { expect, test } from "@playwright/test";

test("task create API persists business planning fields", async ({ request, baseURL }) => {
  const suffix = Date.now();
  const payload = {
    customerRequest: `Customer request ${suffix}`,
    requestedWork: `Prepare business task card ${suffix}`,
    targetDeliveryDate: "2026-04-10",
    buildEstimate: "3 engineering days",
    owner: "Sky",
  };

  const createResponse = await request.post(`${baseURL}/api/tasks`, {
    data: payload,
  });
  const createdTask = await createResponse.json();

  expect(createResponse.status()).toBe(201);
  expect(createdTask.status).toBe("TODO");
  expect(createdTask.customerRequest).toBe(payload.customerRequest);
  expect(createdTask.requestedWork).toBe(payload.requestedWork);
  expect(createdTask.owner).toBe(payload.owner);

  const listResponse = await request.get(`${baseURL}/api/tasks`);
  const tasks = await listResponse.json();

  expect(tasks.some((task: { requestedWork: string }) => task.requestedWork === payload.requestedWork)).toBeTruthy();
});
