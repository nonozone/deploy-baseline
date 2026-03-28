# Project Analysis

This reference focuses on *deployment units* instead of assuming a single repository-wide convergence path. Each analysis pass should return a deployment-unit matrix and a command surface matrix before any confirmation, and treat a single-project repository as the trivial one-unit case.

## Deployment unit inventory

For every candidate unit, capture the following signals; missing essential runtime, hosting, or deploy cues should raise a low-confidence flag that surfaces in the confirmation message. Ownership/boundary metadata is valuable but treated as supplemental context when available.

- **Code paths.** The directory or set of directories that own the deployment surface (e.g., `apps/core`, `services/jobs`, `static/www`).
- **Public surfaces.** Domains, subdomains, routes, hostnames, worker endpoints, or the literal placeholder `internal` for units that do not expose an external surface (tasks, internal jobs, etc.). This keeps the matrix self-consistent even when a unit is purely internal.
- **Hosting signals.** Clues about where the unit runs, such as Docker Compose files, `Dockerfile`s, static export directories, `vercel.json`, `wrangler.toml`, or CDN deploy manifests.
- **Runtime manifests.** Project descriptors (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, `mix.exs`, etc.) that help infer the runtime, statefulness, and build requirements.
- **Deploy commands.** Existing scripts, Makefile targets, npm scripts, or platform CLI commands that are already used to build or publish the surface.
- **Command surfaces.** Distinguish project-level commands (for example `make dev`, repo-level package scripts) from unit-level commands (for example workspace package scripts, `go test`, `cargo test`, service-local scripts). Do not assume every unit exposes `dev`.
- **Ownership boundaries.** Teams, owners, secrets, or runtime IAM policies tied to the unit; capture these when known so verification and rollback boundaries remain clear without forcing low-confidence states when the metadata is absent.

## Per-unit maturity categories

Apply the existing maturity categories at the deployment-unit level rather than globally:

- **Empty or near-empty unit.** Little or no runtime manifest, no deploy automation, and no hosting hints. Action: propose where the baseline artifacts should go and what templated files (compose, env, docs) are still missing for the unit while keeping repo-level placement decisions flexible.
- **Lightweight existing unit.** Code and some scripts exist, but deployment coverage is partial. Action: document missing pieces, fill gaps in build/deploy commands, and normalize naming/structure on a per-unit basis.
- **Heavy existing deployment unit.** Significant tooling already exists for the unit (multiple Compose files, custom scripts, provider manifests). Action: summarize how the existing deployment surface overlaps with the baseline, and expose any forced-vs-conservative choices for that specific unit.

## Hard rules and clarifications

- First detect and list all deployable units before picking baseline actions.
- Do not assume a single deploy strategy for the entire repository—many units share a repo while targeting different deploy platforms.
- **Same repository does not imply the same deploy target.** Each unit may rely on different hosting modes, rollout units, and provider stacks.
- Single confirmation message must include all unresolved unit-level questions.
- When a unit describes a static marketing or CDN surface, prefer documenting its external hosting characteristics rather than defaulting to Docker Compose convergence.
- Treat external platform surfaces (Cloudflare Worker, Vercel function, etc.) as first-class units with their own deploy commands and secrets.

## Deployment unit matrix output requirements

Every matrix row must include these required fields so downstream workflow steps have consistent data:

| Field | Description |
| --- | --- |
| `public_surface` | Hostname, domain, route, or API endpoint tied to the unit. |
| `code_path` | Repository path that owns the unit. For single-project repos this is the project root. |
| `unit_type` | Suggested values: `app`, `api`, `static-site`, `worker`, `task`, etc. |
| `runtime` | Language/runtime descriptor (e.g., `node-http`, `astro-static`, `cloudflare-worker`). |
| `hosting_mode` | Canonical values: `self-hosted`, `external-static-hosting`, `external-platform`. |
| `statefulness` | `stateless`, `stateful`, or `external-state`. |
| `deploy_command` | Known or recommended build/deploy command for the unit. |
| `rollback_unit` | Actual rollback boundary (image tag, git ref, provider release, etc.). |
| `baseline_action` | Recommended path (`converge-self-hosted`, `exclude-from-compose`, `provider-managed`, `document-only`). |

If a repository only contains one deployable surface, the matrix simply has a single row and continues to fulfill all output requirements.

## Command surface matrix output requirements

Every analysis pass must also return a command surface matrix. This makes monorepos and mixed-runner repositories operator-readable without forcing every unit command into the root `Makefile`.

| Field | Description |
| --- | --- |
| `scope` | `project-level` or `unit-level`. |
| `unit_name` | Human-readable unit label or `repo` for project-level rows. |
| `code_path` | Repository path that owns the command surface. |
| `runner` | `make`, `pnpm`, `npm`, `bun`, `go`, `cargo`, `python`, etc. |
| `available_commands` | Commands or scripts actually present. |
| `missing_expected_commands` | Expected but absent commands, especially missing `dev/build/test/typecheck` signals. |
| `recommended_entry` | The command the developer should use first for this scope. |

Hard rules:

- Do not assume every workspace package exposes `dev`.
- Do not silently invent root aliases for unit commands that already work through the unit-native runner.
- Report missing unit-level scripts plainly when a package only exposes `build/test/typecheck`.

## Always report per-unit

- Detected repository root (for context, not for defining the deploy target).
- Current assets and manifests tied to each unit.
- Current command surfaces by scope and unit.
- Missing baseline pieces per unit.
- Any unit-level risks, ownership gaps, or low-confidence detections.
