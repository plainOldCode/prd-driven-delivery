import type { CreateBusinessTaskRequest } from "./DTO/CreateBusinessTaskRequest";
import type { SampleTaskDto } from "./DTO/SampleTaskDto";
import { httpGet, httpPost } from "./http";

export function fetchTasks(): Promise<SampleTaskDto[]> {
  return httpGet<SampleTaskDto[]>("/tasks");
}

export function createTask(request: CreateBusinessTaskRequest): Promise<SampleTaskDto> {
  return httpPost<SampleTaskDto>("/tasks", request);
}
