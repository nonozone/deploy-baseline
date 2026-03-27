# Env Placeholder Normalization Design

**Date:** 2026-03-27

## Goal

Normalize placeholder values in `deploy/env/*.env.example` so new adopters can distinguish runnable defaults from values that must be replaced.

## Problem

The current env examples mix several placeholder styles:

- `change-me`
- `change-me-in-production`
- `replace-me`
- concrete-looking examples such as `https://api.example.com`

This is workable, but inconsistent. The inconsistency leaks into `preflight.sh`, which currently knows about the old `change-me` placeholders and therefore drifts from the env examples if the examples change.

## Decision

Use a small, explicit placeholder contract:

- Runnable non-sensitive defaults stay concrete.
- Sensitive values use `replace-me`.
- Image tags that must be pinned use `replace-with-git-sha`.
- Readable external examples may use `example.com`-style hostnames when the value is not a secret.

## Rules

### Runnable defaults

Keep concrete defaults for values that help the template remain understandable or locally operable:

- `sampleapp`
- `127.0.0.1`
- `8000`
- `5432`
- `db`
- `/health`

### Sensitive values

Use `replace-me` for secrets or credentials that must not survive project adoption:

- `DB_PASSWORD`
- session or app secrets
- provider tokens or API secrets

### Version-sensitive image placeholders

Use `replace-with-git-sha` for image tags that should be pinned before production deploy.

### Readable external examples

Use readable non-secret examples when they improve comprehension:

- `https://api.example.com`
- `us-east-1`

## Scope

In scope:

- `template/deploy/env/*.env.example`
- skill-bundled copies of those env files
- template preflight checks
- docs and skill rules that describe placeholder expectations

Out of scope:

- changing the root `.env.example`
- redesigning production secret sourcing

## Result

After this change:

- env examples become easier to scan
- sensitive values are visually obvious
- docs explain the placeholder policy
- `preflight.sh` validates the same policy the docs describe
