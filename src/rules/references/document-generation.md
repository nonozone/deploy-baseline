# Document Generation

Use this reference when creating or rewriting deployment documentation.

Treat deployment docs as an operator-facing view of the chosen baseline actions. In mixed-surface repositories, the docs must make the deployment-unit matrix explicit rather than pretending the whole repo shares one deploy path.

## Required docs

Generate or update:

- `deploy/README.md`
- project-specific baseline notes when the repo keeps them
- unit-specific deploy notes only when one shared `deploy/README.md` would become ambiguous or too large

## Shared doc shape

Prefer one shared `deploy/README.md` that covers the whole repository and includes deployment-unit sections.

The shared document should explicitly show:

- which units are `self-hosted`
- which units are `external-static-hosting`
- which units are `external-platform`
- which units are included in `make deploy`
- which units are excluded from rollback or have provider-owned rollback

## `deploy/README.md` minimum sections

Include:

1. deployment scope
2. deployment unit matrix
3. per-unit hosting and ownership summary
4. prerequisites
5. local run mode
6. service release split
7. standard directory layout
8. env files and secret sourcing
9. deploy checks
10. deploy flow
11. startup contract and completion criteria
12. logs and health checks
13. rollback flow and rollback boundaries
14. persistence and volume notes
15. provider-specific caveats
16. common troubleshooting
17. project-specific notes

## Per-unit documentation requirements

### Self-hosted units

Document:

- how the unit enters `docker-compose.*` or why it is intentionally excluded
- whether `make dev` starts it, and whether `dev_mode` is `full-docker` or `hybrid`
- build, deploy, log, and rollback commands
- healthcheck path, startup contract, migration behavior, and completion criteria

### External static hosting units

Document:

- build command and output directory
- routing or base-path assumptions
- host requirements such as rewrites, redirects, headers, or CDN notes
- env contract: build-time vars vs runtime vars
- deployment trigger and whether the unit is excluded from Compose and self-hosted rollback

Do not document static units as if they must be Dockerized unless the developer explicitly chose self-hosting.

### External platform units

Document:

- platform name and manifest/config path
- deploy command and local dev command when applicable
- required secrets and ownership boundaries
- rollback boundary or explicit statement that rollback is unavailable or provider-owned
- whether the unit is included in or excluded from self-hosted rollback

## Source of truth

Use:

- the deploy baseline standard
- the deployment SOP
- facts discovered in the target project

Do not leave the document as generic template prose when the project already exposes concrete ports, services, domains, commands, or provider assets.

When the project uses stateful containers, explicitly document:

- named volumes used
- bind mounts used
- any major-version-specific storage caveats
- backup caution before changing mount targets
