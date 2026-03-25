# Transformation Rules

Read this before changing files.

## Target structure

Converge toward:

- `Makefile`
- `.env.example`
- `docker-compose.yml`
- `docker-compose.dev.yml`
- `docker-compose.prod.yml`
- `scripts/`
- `deploy/README.md`
- `deploy/env/`
- `deploy/scripts/`

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
- Keep `deploy/env/*.env.example` for deploy or runtime-specific files.
- Mark provider-specific keys as optional unless universally required.
- Do not mix local-only variables and production-only variables without comments.
- Avoid placeholder inconsistency such as mixing empty values, `replace-me`, and real-looking secrets without explanation.
