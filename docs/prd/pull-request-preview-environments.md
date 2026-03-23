# Pull Request Preview Environments PRD

Status: Implemented and extended. This PRD now backs the preview-environment scripts, local k3d preview URLs, dashboard, and workflow wiring in the repo.

## Background

The current workspace already proves a docs-first path from PRD to backend, frontend, QA, and local infrastructure validation.

That is useful for engineering credibility, but it still leaves one expensive step to human imagination: a reviewer often has to infer the result from a diff, a test log, or a static screenshot.

For fast product decisions, that is not enough. A reviewer should be able to open a live URL for a branch or pull request and decide with human eyes whether the change is worth merging.

## Problem

Without branch-aware preview environments:

- product and design reviewers depend on screenshots or local setup help
- human approval happens late because a working slice is not visible until after merge or manual deployment
- code review stays centered on diffs even when the real question is whether the result is acceptable in the browser
- preview setup becomes a one-off manual task instead of part of the delivery system

## Goal

Add a preview-environment feature that can create an isolated release per branch or pull request, expose a deterministic preview URL, and make that URL easy to surface in review.

## Users

- A product manager or business reviewer who wants to approve or reject a change by looking at it
- A designer who wants to validate the rendered result without pulling the branch locally
- An engineer who wants branch-specific deployment proof before merge
- A reviewer who wants to see tests and a preview URL attached to the same pull request

## Requirements

1. A preview environment can be derived from either a pull request number or a branch name.
2. Each preview gets an isolated namespace and release name so multiple changes can exist at once.
3. Each preview gets a deterministic ingress host or URL that can be shared in review.
4. The deployment flow can override backend and frontend images for the preview release.
5. The system can validate that the preview workloads are ready before advertising the URL.
6. The workflow can remove preview resources when the pull request is closed.
7. The feature must work locally against `k3d` as a realistic rehearsal for remote preview environments.
8. Local preview rehearsals should expose directly usable browser URLs, not only host-header curl examples.
9. A reviewer or engineer should be able to open one lightweight dashboard to observe active previews and their status.
10. Approval-driven merge behavior should be possible when the repository explicitly enables it.

## Success Criteria

- A pull request can produce a preview URL without manual Helm editing.
- A human reviewer can look at a branch-specific deployment before merge.
- A local `k3d` rehearsal can expose branch or PR previews at directly usable URLs.
- A local dashboard can show active previews, status, and links in one place.
- The preview flow leaves an auditable trail through docs, scripts, workflow logs, and Helm release history.
- The repo shows that review can move from “read the diff” to “open the preview and decide.”

## Out Of Scope

- Multi-tenant authentication for preview environments
- Cost optimization for many concurrent previews
- Automatic screenshot generation for every pull request
- Approval logic beyond exposing the preview and test status
- Production-grade cleanup policies beyond basic delete-on-close behavior

## Why This Matters

The value of an AI-assisted delivery system is not only that it can generate working slices quickly.

The bigger value is that it can reduce the cost of human validation. Preview environments make that visible:

- engineering can ship a candidate faster
- reviewers can decide based on a working result
- merge risk drops because the change is no longer hypothetical

That shifts the bottleneck away from implementation and toward faster, clearer selection.
