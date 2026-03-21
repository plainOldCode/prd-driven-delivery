# Task Lifecycle And Status Rules Spec

Status: Planned next feature. This document describes the next implementation slice; the current codebase still only exposes health and read-only task list behavior.

Source PRD: [`docs/prd/task-lifecycle-and-status-rules.md`](../prd/task-lifecycle-and-status-rules.md)

## Scope Summary

Add one meaningful workflow feature on top of the existing task list:

- task creation
- constrained status transitions
- blocked-task reasoning
- read-only handling for completed work

This spec is intended to drive backend, frontend, and e2e implementation together.

## Backend Contract

### Endpoints

`GET /api/tasks`

- Returns the current task list ordered by creation time or ID

`POST /api/tasks`

- Creates a new task
- Request body:

```json
{
  "title": "Prepare release notes"
}
```

- Response body:

```json
{
  "id": 12,
  "title": "Prepare release notes",
  "status": "TODO",
  "blockedReason": null,
  "createdAt": "2026-03-21T08:00:00Z",
  "updatedAt": "2026-03-21T08:00:00Z"
}
```

`PATCH /api/tasks/{id}`

- Updates status and, when needed, `blockedReason`
- Request body:

```json
{
  "status": "BLOCKED",
  "blockedReason": "Waiting for API schema review"
}
```

### Error Shape

Validation and transition failures should return a machine-readable response:

```json
{
  "code": "INVALID_STATUS_TRANSITION",
  "message": "Task cannot move from TODO to DONE",
  "fieldErrors": {
    "status": "Allowed next statuses: IN_PROGRESS, BLOCKED"
  }
}
```

## Validation And Business Rules

### Field Rules

- `title` is required
- `title` length: 3 to 100 characters after trimming
- `blockedReason` is optional except when status is `BLOCKED`
- `blockedReason` length: 10 to 200 characters after trimming when provided

### Status Set

- `TODO`
- `IN_PROGRESS`
- `BLOCKED`
- `READY`
- `DONE`

### Allowed Transitions

| From | To |
|------|----|
| `TODO` | `IN_PROGRESS`, `BLOCKED` |
| `IN_PROGRESS` | `TODO`, `BLOCKED`, `READY` |
| `BLOCKED` | `TODO`, `IN_PROGRESS` |
| `READY` | `IN_PROGRESS`, `BLOCKED`, `DONE` |
| `DONE` | none |

### Special Rules

- Moving to `BLOCKED` requires `blockedReason`
- Moving away from `BLOCKED` clears `blockedReason`
- Moving to `DONE` from anything other than `READY` must fail
- A `DONE` task cannot be updated through the normal patch endpoint

## Database Impact

Existing `sample_task` data is not enough for this feature.

Expected schema changes:

- add `blocked_reason` nullable column
- add `updated_at` timestamp column
- ensure seeded rows can coexist with the new fields

Liquibase should own the schema change so local Docker and k3d deployments stay aligned.

## Frontend Behavior

### UI Surface

The task panel should support:

- create task input
- visible status badges
- status change control
- blocked reason input when moving to `BLOCKED`

### Required States

- initial loading
- optimistic submit disabled state
- successful create/update refresh
- field-level validation error
- rejected transition error
- read-only treatment for `DONE`

### Copy Expectations

- Invalid transitions should explain the rule, not just say “failed”
- `BLOCKED` tasks should display the blocking reason inline
- `DONE` tasks should indicate they are closed and not editable

## E2E Acceptance Criteria

The e2e suite should prove at least these scenarios:

1. Create a new task and verify it appears with status `TODO`
2. Move `TODO -> IN_PROGRESS -> READY -> DONE`
3. Attempt `TODO -> DONE` and verify the request is rejected with a visible error
4. Attempt to move a task to `BLOCKED` without a reason and verify validation feedback
5. Move a task to `BLOCKED` with a valid reason and verify the reason is rendered in the UI

## Rollout And Non-Goals

This feature is still intentionally small.

It should not introduce:

- authentication
- background jobs
- multi-user conflict handling
- pagination
- audit trails

The purpose is to demonstrate one level of meaningful product complexity, not to build a full task management product.
