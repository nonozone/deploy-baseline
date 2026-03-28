# Transformation Rules

Read this before changing files.

## Target structure (self-hosted convergence only)

Only `converge-self-hosted` units should converge toward the full baseline structure.

Converge toward (when appropriate):

- `Makefile`
- `.env.example`
- `docker-compose.yml`
- `docker-compose.dev.yml`
- `docker-compose.prod.yml`
- `scripts/`
- `deploy/README.md`
- `deploy/env/`
- `deploy/scripts/`

Same repo does not imply same deploy directory or the same convergence path.
It is valid for a repo to have:

- one or more self-hosted units in Compose
- static units that are excluded from Compose and documented for external hosting
- provider-managed units that are excluded from Compose and documented for platform deploy

## Apply the right strategy

### New or near-empty project

- generate from `assets/template/`
- adapt placeholders to the detected stack, mode, and database

### Lightweight existing project

- keep useful project specifics
- rename or reorganize only when that increases alignment with the baseline
- fill missing baseline pieces

### Heavy existing deployment project

- summarize rewrites up front
- preserve non-trivial project logic by migration, compatibility wrappers, or explicit notes
- avoid silent deletion

## Baseline actions (per deployment unit)

Each deployment unit must have a `baseline_action`. These are first-class outcomes, not "out of scope".

### `converge-self-hosted`

Use when the unit is `hosting_mode=self-hosted` and should be operated via Docker/Compose + baseline deploy docs.

Minimum expectations:

- include the unit in `docker-compose.*` if it is meant to run under Compose
- ensure `make dev/build/test/deploy/rollback/logs` targets exist when they make sense
- ensure `deploy/README.md` documents deploy + rollback for this unit

### `exclude-from-compose`

Use when the unit is a deployment surface but should not be run or shipped via `docker-compose.*`.

Common cases:

- static sites intended for external static hosting (default)
- self-hosted units that are intentionally host-managed (systemd, vendor runtime, existing platform constraints)
- units that share the repo but have a separate deploy system you must not rewrite

Minimum expectations:

- do not add the unit to `docker-compose.*`
- document how it is built/deployed and how it is rolled back (or explicitly state rollback is provider-owned / manual)
- document boundaries: who owns the platform config, where secrets live, what is safe to change in-repo

### `provider-managed`

Use when the unit is `hosting_mode=external-platform` (Workers, functions, PaaS apps, etc).

Provider-managed units are first-class deployment surfaces, but must not be forced into Docker/Compose by default.

Minimum expectations:

- preserve or introduce the provider manifest/config (example: `wrangler.toml`)
- document deploy command, local dev command (if any), and rollback boundary
- document required secrets and where they live (dashboard, CLI, env vars)

### `document-only`

Use when the unit exists but the baseline should not alter its deploy machinery in this change set.

Minimum expectations:

- document how it is deployed today
- document what is unknown or blocked (missing commands, missing ownership, missing access)

Tie-break rule:

- If the unit is `hosting_mode=external-platform`, do not use `document-only`. Use `provider-managed` (even if the output is documentation-only in practice) so the required fields are captured.
- If the unit is `hosting_mode=external-static-hosting`, do not use `document-only`. Use `exclude-from-compose` so the unit stays baseline-in-scope and is not accidentally treated as "ignore".
- Only use `document-only` when you cannot safely choose or execute a stronger action due to missing access/ownership/unknowns, and you explicitly record what is missing and who owns it.

## System Config Protection

When touching existing machine-level or shared service config, default to merge rather than overwrite.

Applies to:

- `Caddyfile`
- `nginx.conf`
- systemd unit files
- existing CI or CD workflows
- host-level firewall rules

Rules:

- Never replace the whole file unless the developer explicitly chose forced convergence.
- Prefer backup plus append plus validate plus reload.
- If the file already contains unrelated sites or services, preserve them.

## Required command surface

Converge on these targets when they make sense for the project:

- `make dev`
- `make build`
- `make test`
- `make deploy`
- `make rollback`
- `make logs`
- `make help`

Complex logic belongs in scripts, not in `Makefile`.

For monorepos and multi-unit repositories:

- treat the root `Makefile` as the project-level command surface
- preserve unit-level commands in their native runner (`pnpm`, `npm`, `bun`, `go`, `cargo`, etc.)
- do not force every unit command into the root `Makefile`
- only add root aliases for unit commands when they are truly high-frequency project conventions
- if a unit lacks `dev`, report that explicitly instead of adding a fake placeholder command

## Documentation rules

- `deploy/README.md` must follow the deployment SOP shape
- if the project deviates from the baseline, document the reason instead of pretending full conformity

## Env Template Layout

Group env example files by concern.

Recommended group order:

1. project or runtime
2. database
3. publish ports
4. auth or secrets
5. provider-specific config
6. observability or verification

Rules:

- Keep `.env.example` for local or dev.
- Prefer `.env.example` as a minimal generic first-run entry surface instead of a full runtime dump.
- Keep `deploy/env/*.env.example` for deploy or runtime-specific files.
- Keep database, provider, and fuller runtime variables in `deploy/env/*.env.example` unless the local flow truly requires them at the root.
- Use `replace-me` for sensitive placeholders, `replace-with-git-sha` for image-tag placeholders, and keep non-sensitive runnable defaults concrete when that improves usability.
- Mark provider-specific keys as optional unless universally required.
- Do not mix local-only variables and production-only variables without comments.
- Avoid placeholder inconsistency such as mixing empty values, `replace-me`, and real-looking secrets without explanation.

## External handling expectations

### External static hosting surfaces

Minimum expected handling:

- identify and document the build command (for example `npm run build`)
- identify and document the output directory (`dist/`, `build/`, `out/`, etc)
- document routing/base-path assumptions (SPA fallback, asset prefix, subpath deploy)
- document host requirements (SPA rewrites, redirects, headers, custom error pages) when relevant
- document DNS assumptions (custom domain, required `A/AAAA/CNAME` records, apex vs subdomain) when relevant
- document CDN assumptions (whether a CDN is used, where caching happens) when relevant
- document cache policy notes (HTML vs assets, immutable asset caching, invalidation/purge expectations) when relevant
- document env contract: build-time vars vs runtime vars, and where secrets are stored
- do not Dockerize by default; only do so if the developer explicitly requests self-hosting

### External platform assets (provider-managed)

Minimum expected handling (example: Cloudflare Workers):

- document the platform name (example: Cloudflare Workers, AWS Lambda, Fly.io, etc)
- ensure a manifest/config exists and is referenced (example: `wrangler.toml`)
- document deploy command and any required local dev command
- document required secrets and ownership boundaries (who can rotate, where they live)
- document rollback boundary (provider version, deployment id) or explicitly state if rollback is not available
- explicitly document whether this unit is included in self-hosted rollback (`included` / `excluded`) and what that means operationally
