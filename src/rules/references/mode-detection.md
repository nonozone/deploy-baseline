# Mode Detection

Use this reference to decide **mode per deployment unit**.

Do not assume one repo-wide mode in a monorepo.

## Two related fields (do not conflate)

- `hosting_mode` (delivery): `self-hosted` | `external-static-hosting` | `external-platform`
- `dev_mode` (local dev for a self-hosted unit): `full-docker` | `hybrid`

Static sites and provider-managed units must not be folded into repo-wide Docker assumptions.

## Decide `hosting_mode` first (per unit)

### `external-static-hosting`

Prefer this when the unit is a static site (marketing, docs, static export) and is intended to be hosted by a static provider (Pages, S3/CloudFront, Netlify, Vercel static, etc).

Default: do not Dockerize.

### `external-platform`

Prefer this when the unit is deployed to a provider-managed platform (Workers/functions/PaaS) with its own CLI, manifest, and release model.

Default: do not Dockerize or force Compose.

### `self-hosted`

Use this when the unit is intended to run on infrastructure you control (VM/bare metal/Kubernetes) and you own the runtime process model.

Only self-hosted units should be considered for Docker/Compose convergence.

## Full Docker

Prefer `dev_mode=full-docker` for a **self-hosted** unit when:

- core app services already run in Compose
- local developer flow is container-first
- hot reload and service-to-service dependencies already assume containers

## Hybrid development

Prefer `dev_mode=hybrid` for a **self-hosted** unit when:

- stateful services such as DB or cache use containers
- the main app runs locally with framework-native commands
- the repo already has local dev scripts that should remain first-class

Hybrid is common in mixed-hosting monorepos:

- shared infra (DB/cache) in Compose
- backend service in Compose or local
- static site built locally, hosted externally
- provider-managed workers deployed via provider CLI

## If uncertain

Do not guess quietly.

Include the uncertainty in the one confirmation message and ask the developer to confirm **per unit**.

## Output language

State:

- unit name / code path
- chosen `hosting_mode`
- if `self-hosted`: chosen `dev_mode`
- evidence
- what `make dev` will start (and which units are excluded)
