# Business Task Intake And Planning Spec

Status: Implemented initial slice. This spec describes the current backend, frontend, and e2e behavior built from the matching PRD.

Source PRD: [`docs/prd/business-task-intake-and-planning.md`](../prd/business-task-intake-and-planning.md)

## Scope Summary

The current implementation adds one business-task intake slice on top of the original read-only task list:

- richer planning fields on each task
- `POST /api/tasks` for validated business-task creation
- frontend intake form plus planning-oriented task rendering
- API and UI smoke coverage for create and read paths

## Backend Contract

### Endpoints

`GET /api/tasks`

- Returns the current task list ordered by ID
- Response fields:
  - `id`
  - `title`
  - `status`
  - `createdAt`
  - `customerRequest`
  - `requestedWork`
  - `targetDeliveryDate`
  - `buildEstimate`
  - `owner`

`POST /api/tasks`

- Creates a new task with default status `TODO`
- Request body:

```json
{
  "customerRequest": "Customer needs a visible delivery task",
  "requestedWork": "Prepare business task intake flow",
  "targetDeliveryDate": "2026-04-10",
  "buildEstimate": "3 engineering days",
  "owner": "Sky"
}
```

- Notes:
  - `title` is derived from `requestedWork` for compatibility with the existing task model
  - `requestedWork` remains the business-facing field shown in the UI

### Validation

- `customerRequest` is required
- `requestedWork` is required
- `targetDeliveryDate` is required
- `buildEstimate` is required
- `owner` is required

Validation errors return:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Task input is invalid",
  "fieldErrors": {
    "owner": "Owner is required"
  }
}
```

## Database Impact

The `sample_task` table now stores:

- `customer_request`
- `requested_work`
- `target_delivery_date`
- `build_estimate`
- `owner_name`

Existing seed rows are backfilled through Liquibase for older databases and created directly by the init SQL for fresh databases.

## Frontend Behavior

- The main task panel now includes a business-task intake form.
- The form posts to `POST /api/tasks`.
- Field-level validation messages are rendered from backend responses.
- Successful create refreshes the task list from the backend.
- Each task card shows:
  - short title
  - requested work
  - customer request
  - delivery date
  - estimate
  - owner

## E2E Coverage

The smoke suite now proves:

1. `GET /api/tasks` includes the planning fields on seeded rows
2. `POST /api/tasks` creates a new task with status `TODO`
3. The UI task intake form can create a task and render the new planning data
