# Production Env Sync Design

**Date:** 2026-03-28

## Goal

Handle the common case where `deploy/env/app.prod.env.example` gains new keys while an existing `deploy/env/app.prod.env` in a real project still reflects an older structure.

## Problem

The current baseline only copies `app.prod.env.example` on first setup. After that:

- new keys added to the example do not reach the real `app.prod.env`
- the drift stays silent until deployment or runtime reveals it
- there is no standard non-destructive sync path

This creates avoidable breakage when the baseline evolves.

## Decision

Introduce a non-destructive env sync path with three behaviors:

1. `make env-sync` inserts missing active keys from `app.prod.env.example` into `app.prod.env` following the same group order when possible
2. `make setup` invokes the same sync path so existing projects get missing keys inserted during re-setup
3. `make deploy-check` detects drift and fails with a clear instruction instead of silently proceeding

## Safety rules

- Never overwrite existing values in `app.prod.env`
- Only insert missing active assignment keys from `app.prod.env.example`
- Prefer the same group position as the example instead of appending everything to the end of the file
- Report which keys were added
- Keep deployment checks non-mutating; they may instruct the operator to run `make env-sync`, but should not rewrite production env files during deploy

## Scope

In scope:

- template `Makefile`
- template `scripts/setup.sh`
- template deploy scripts
- skill-bundled template copies
- docs and skill guidance

Out of scope:

- generic merge of commented optional keys
- automatic mutation during `make deploy`
- solving every possible env-drift scenario across arbitrary custom env files

## Result

After this change:

- baseline upgrades can add new production env keys safely
- existing projects get a standard sync command
- deploy checks explain env drift instead of failing cryptically
- the skill can converge existing projects more safely by following the same non-destructive rule
