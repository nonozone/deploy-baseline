# Project Analysis

Use this reference to classify the target directory and inventory its deployment surface.

## Inventory checklist

Look for:

- `Makefile`
- `.env.example`
- `docker-compose.yml`
- `docker-compose.dev.yml`
- `docker-compose.prod.yml`
- `scripts/`
- `deploy/README.md`
- `deploy/env/`
- `deploy/scripts/`
- existing app-specific deploy scripts
- app runtime manifests such as `package.json`, `pyproject.toml`, or `go.mod`

## Classification

### Empty or near-empty

Signs:

- almost no app manifests
- no deployment files
- no deploy scripts

Action:

- propose baseline generation from the bundled template

### Lightweight existing project

Signs:

- app code exists
- some scripts or env files exist
- deployment surface is partial or inconsistent

Action:

- propose gap-filling plus naming and structure convergence

### Heavy existing deployment project

Signs:

- multiple Compose files or custom deploy scripts already exist
- a non-trivial `Makefile` already orchestrates deployment
- `deploy/` already contains meaningful project logic

Action:

- summarize conflicts, overwritten areas, preserved areas, and the forced-vs-conservative choice

## Always report

- detected project root
- current assets
- missing baseline pieces
- highest-risk edits
