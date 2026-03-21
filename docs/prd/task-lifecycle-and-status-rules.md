# Task Lifecycle And Status Rules PRD

## Background

The current workspace proves that backend, frontend, and e2e-test can connect around a task list and a business-task intake flow.

That is enough to show wiring and validated create behavior, but not enough to show a real feature workflow with lifecycle rules, blocked-state handling, and acceptance criteria around status transitions.

This feature exists to raise the complexity by one step without becoming a large CRUD system.

## Problem

The workspace can create and display tasks, but it cannot express how work should move through a delivery lifecycle.

Without explicit lifecycle rules:

- the backend contract is too thin
- the frontend has no meaningful validation or error handling
- the e2e suite cannot prove a real product rule

## Goal

Introduce a task lifecycle feature that makes status changes meaningful and testable across backend, frontend, and e2e-test.

## Users

- A solo engineer using the workspace to organize feature work
- A hiring manager or reviewer evaluating whether the repo demonstrates product-to-delivery thinking

## Requirements

1. The existing task intake flow remains the entry point and creates tasks with an initial status of `TODO`.
2. Users can move a task through the statuses `TODO`, `IN_PROGRESS`, `BLOCKED`, `READY`, and `DONE`.
3. If a task is moved to `BLOCKED`, a non-empty `blockedReason` is required.
4. A task can move to `DONE` only from `READY`.
5. A task in `DONE` is read-only from the normal editing flow.
6. The frontend must show success, validation error, loading, and rejected-transition states clearly.
7. The e2e suite must cover one valid lifecycle path and at least one invalid transition.

## Success Criteria

- The backend enforces status transition rules instead of trusting the client.
- The frontend reflects server-side validation errors without hiding them.
- A reviewer can read the PRD and understand what backend, frontend, and QA changes are expected.

## Out Of Scope

- Multi-user collaboration
- Authentication or authorization
- Task comments or attachments
- Audit history
- Bulk editing

## Why This Matters

This is the smallest feature that can show the repo is more than a skeleton.

It creates a real bridge from product rules to:

- backend validation
- frontend state handling
- e2e acceptance coverage
