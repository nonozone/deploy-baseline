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
