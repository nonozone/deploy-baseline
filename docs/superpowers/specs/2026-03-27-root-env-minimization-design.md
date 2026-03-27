# Root Env Minimization Design

**Date:** 2026-03-27

## Goal

Reduce first-run configuration burden by turning the root `.env.example` into a generic minimal entry file, while keeping deployment and database runtime details in `deploy/env/*.env.example`.

## Problem

The current root `.env.example` exposes database variables directly. That makes the first edit surface heavier than necessary for new adopters, even though most of those values belong to runtime or deploy concerns rather than the initial project entry surface.

There is also a template coupling risk: the dev Compose path currently reads `.env`, so removing `DB_*` variables from the root env without changing Compose defaults would make the template incomplete.

## Decision

Adopt a two-layer env model:

1. Root `.env.example` stays minimal and generic.
2. `deploy/env/*.env.example` remains the place for fuller runtime and deploy variables.

To preserve template usability, the Compose templates must carry safe database defaults for local development when the root `.env` no longer defines `DB_*`.

## Scope

In scope:

- `template/.env.example`
- `skills/deploy-baseline-kit/assets/template/.env.example`
- template Compose defaults that currently require `DB_*` in root `.env`
- template-facing docs and skill-facing rules that describe env layout

Out of scope:

- redesigning the entire env contract
- changing deploy script behavior
- changing the PostgreSQL baseline itself

## Resulting Shape

### Root `.env.example`

Keep only the minimal local entry variables:

- `COMPOSE_PROJECT_NAME`
- `LOCAL_RUNTIME_MODE`
- `APP_PORT`
- `APP_PUBLISH_IP`
- `APP_PUBLISH_PORT`
- `APP_IMAGE`

Also explain that database and deploy/runtime variables live in `deploy/env/*.env.example`.

### Compose defaults

For local and template-safe operation, database-related substitutions in `docker-compose.yml` should use defaults:

- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `DB_PORT`

This keeps the template operable even when root `.env` is intentionally minimal.

## Documentation updates

Update repository docs and skill guidance so they explicitly state:

- root `.env.example` is a first-run entry surface
- `deploy/env/*.env.example` holds fuller runtime or deployment variables
- the skill should prefer a small, generic root env instead of dumping all runtime variables there
