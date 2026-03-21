import type { SampleTaskDto } from "./DTO/SampleTaskDto";
import { httpGet } from "./http";

export function fetchTasks(): Promise<SampleTaskDto[]> {
  return httpGet<SampleTaskDto[]>("/tasks");
}
