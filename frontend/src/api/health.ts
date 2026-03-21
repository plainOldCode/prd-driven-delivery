import type { HealthDto } from "./DTO/HealthDto";
import { httpGet } from "./http";

export function fetchHealth(): Promise<HealthDto> {
  return httpGet<HealthDto>("/health");
}
