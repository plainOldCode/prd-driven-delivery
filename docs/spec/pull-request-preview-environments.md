# Pull Request Preview Environments Spec

Status: Implemented and extended. This spec describes the current preview-environment workflow, direct local URLs, dashboard, and approval wiring built from the matching PRD.

Source PRD: [`docs/prd/pull-request-preview-environments.md`](../prd/pull-request-preview-environments.md)

## Scope Summary

The current implementation adds one preview-delivery slice on top of the existing CI and k3d setup:

- deterministic preview IDs derived from pull request numbers or branch names
- isolated Helm release, namespace, and ingress host generation
- direct local preview URLs for `k3d` rehearsals
- a generated dashboard for observing active previews
- GitHub Actions workflow for build, deploy, test, PR comment, and cleanup
- a guarded approval workflow that can enable merge on approval
- local `k3d` preview rehearsal through Makefile targets and the same scripts

## Infrastructure Contract

### Preview Identity

The preview scripts derive a stable identifier using these rules:

1. use `pr-<number>` when a pull request number is available
2. otherwise slugify the branch name
3. otherwise accept an explicit preview key from the CLI

That identifier drives:

- namespace
- Helm release name
- ingress host
- preview URL output

### Scripts

`infrastructure/k3s/scripts/pr-env-create.sh`

- computes preview identifiers
- installs or upgrades the Helm release
- accepts image overrides for backend and frontend preview images
- labels and annotates the preview namespace for dashboard discovery
- writes preview outputs for GitHub Actions when `PREVIEW_OUTPUT_FILE` is set

`infrastructure/k3s/scripts/pr-env-test.sh`

- waits for backend, frontend, nginx, and database readiness
- prints namespace and ingress state
- can smoke-check previews either through a direct local URL or a host-header gateway route

`infrastructure/k3s/scripts/pr-env-delete.sh`

- resolves the same preview identity
- uninstalls the Helm release
- deletes the preview namespace

`infrastructure/k3s/scripts/pr-env-dashboard.sh`

- inspects namespaces labeled as active previews
- renders an HTML dashboard with preview links, status, and rollout summaries
- supports a local observation loop during review

### Helm Support

The chart now supports preview deployment needs through:

- overridable backend and frontend image names
- per-container `imagePullPolicy`
- optional `imagePullSecrets`
- ingress annotations for external preview controllers

## GitHub Actions Behavior

`.github/workflows/preview-environment.yml`

- triggers on pull request open, synchronize, reopen, and close
- builds backend and frontend preview images
- pushes those images to GHCR
- deploys the preview release with branch or PR-specific identity
- validates rollout with the shared preview test script
- posts or updates a pull request comment with the preview URL
- deletes the preview namespace when the pull request closes

`.github/workflows/preview-approval.yml`

- listens for approved pull-request reviews
- only acts when `PREVIEW_AUTO_MERGE_ON_APPROVAL=true`
- prefers GitHub auto-merge and falls back to direct merge when possible
- relies on the existing close workflow to remove the preview after merge

### Required Repository Configuration

The workflow expects these repository settings for remote preview deployment:

- secret: `PREVIEW_KUBECONFIG_B64`
- variable: `PREVIEW_BASE_DOMAIN`

Optional repository variables:

- `PREVIEW_INGRESS_CLASS`
- `PREVIEW_IMAGE_PULL_SECRET`
- `PREVIEW_URL_SCHEME`
- `PREVIEW_AUTO_MERGE_ON_APPROVAL`
- `PREVIEW_AUTO_MERGE_METHOD`

When the required settings are missing, the workflow reports that preview deployment is skipped instead of pretending it ran.

## Local Preview Behavior

The Makefile exposes a local preview rehearsal path against `k3d`:

1. build and import preview images
2. create a PR-style preview release
3. wait for rollout
4. curl the preview through the local ingress entrypoint using the preview host header
5. delete the namespace when done

This keeps the preview flow testable without needing a remote cluster for every change.

### Local URL Contract

The local preview path uses hosts like:

- `http://pr-204.localhost:8088`
- `http://feature-preview-url.localhost:8088`

That means a reviewer can open a local preview directly in a browser without manually constructing `Host` headers.

### Dashboard Contract

The local observation path is:

1. create one or more previews
2. generate the dashboard with `make pr-env-dashboard`
3. open the generated HTML file
4. use the listed URLs and readiness summaries to decide whether to keep, merge, or delete a slice

## Acceptance Criteria

1. A preview namespace can be created from a PR number without manual Helm edits.
2. A preview namespace can also be created from a branch name when no PR number exists.
3. The preview test script can prove workload readiness for backend, frontend, nginx, and database.
4. A GitHub pull request can receive a preview URL comment when preview deployment is configured.
5. The preview namespace can be deleted cleanly on pull request close.

## Rollout And Non-Goals

- This slice wires the preview workflow and local rehearsal path. It does not solve enterprise DNS, auth, or cost governance by itself.
- A real deployment still depends on cluster credentials, registry access, and a base domain controlled outside the repo.
- Preview environments help people decide faster, but they do not replace acceptance criteria, QA, or merge discipline.
