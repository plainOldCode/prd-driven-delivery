# Sample Feature PRD

## Background

The example workspace needs a minimal feature that shows how the backend, frontend, and e2e-test projects connect to each other.

## Requirements

1. Users can see the current workspace components on the frontend home page.
2. The frontend calls the backend `/api/health` endpoint and displays the service status.
3. The e2e smoke tests validate both the home page render and the health API response.
4. The k3s test environment should be able to run backend, frontend, database, and nginx together.

## Out of Scope

- Authentication and authorization
- Real data CRUD flows
- Full PR-based namespace lifecycle automation
