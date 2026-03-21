# Business Task Intake And Planning PRD

Status: Candidate next feature. This PRD describes a business-facing task slice that could follow the current read-only task demo.

## Background

The current workspace proves the wiring between backend, frontend, database, e2e-test, and local infrastructure.

That is useful as a delivery skeleton, but the task shape is still too technical and too thin for business planning.

Real work intake usually starts with a customer or stakeholder request, not with an internal engineering title alone.

## Problem

The current task model can show a title, status, and creation time, but it cannot answer the planning questions that matter to a business-facing workflow:

- who asked for the work
- what exactly is being requested
- when the delivery is expected
- how much effort the build is expected to take
- who is responsible for doing it

Without those fields, the task list is useful as a demo of connectivity, but not as a useful planning artifact.

## Goal

Introduce a small task-planning feature that captures the minimum business context needed to turn a request into a trackable delivery item.

## Users

- A solo engineer or tech lead translating stakeholder requests into delivery work
- A reviewer who wants to see that the workspace can represent both product context and execution ownership

## Requirements

1. A task can record the customer or stakeholder request that triggered the work.
2. A task can record a plain-language description of what is being delivered.
3. A task can record the expected delivery date.
4. A task can record an engineering estimate for the build effort.
5. A task can record who is responsible for doing the work.
6. The frontend should make these fields easy to scan in a task list or detail view.
7. The backend should validate required planning data instead of trusting the client.

## Suggested Data Shape

The exact contract can be refined in a spec, but the feature should cover these concepts:

- `customerRequest`
- `requestedWork`
- `targetDeliveryDate`
- `buildEstimate`
- `owner`

## Success Criteria

- A reviewer can understand a task as a business request, not only as an engineering placeholder.
- The repo gains one credible example of how a PRD can push the task model beyond a seeded demo row.
- The next spec can derive backend validation, frontend form behavior, and e2e coverage from this document.

## Out Of Scope

- Customer comments or long discussion threads
- Attachments or uploaded files
- Team capacity planning across multiple people
- Actual time tracking versus estimated time
- Notifications or reminders

## Why This Matters

This is a small feature, but it moves the task model closer to real delivery work.

It adds the planning context that bridges:

- stakeholder request
- delivery expectation
- engineering estimate
- ownership

That makes the workspace more credible as a product-to-delivery example, not just a technical integration demo.
