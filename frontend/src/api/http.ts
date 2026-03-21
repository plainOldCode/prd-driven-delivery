const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "/api";

interface ApiErrorPayload {
  code?: string;
  message?: string;
  fieldErrors?: Record<string, string>;
}

export class ApiRequestError extends Error {
  status: number;
  code?: string;
  fieldErrors: Record<string, string>;

  constructor(status: number, payload: ApiErrorPayload) {
    super(payload.message ?? `Request failed with status ${status}`);
    this.name = "ApiRequestError";
    this.status = status;
    this.code = payload.code;
    this.fieldErrors = payload.fieldErrors ?? {};
  }
}

async function buildError(response: Response): Promise<ApiRequestError> {
  let payload: ApiErrorPayload = {};

  try {
    payload = (await response.json()) as ApiErrorPayload;
  } catch {
    payload = {};
  }

  return new ApiRequestError(response.status, payload);
}

export async function httpGet<T>(path: string): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`);

  if (!response.ok) {
    throw await buildError(response);
  }

  return (await response.json()) as T;
}

export async function httpPost<T>(path: string, body: unknown): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    throw await buildError(response);
  }

  return (await response.json()) as T;
}
