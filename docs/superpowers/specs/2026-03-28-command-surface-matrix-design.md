# Command Surface Matrix Design

**Date:** 2026-03-28

## Goal

Extend `deploy-baseline-kit` so it models command surfaces explicitly in monorepos and multi-unit repositories, instead of assuming one project-level command layer or assuming every unit exposes the same scripts.

## Problem

The repository already models deployment units, hosting modes, and baseline actions. That is not enough for real monorepos.

In practice, repositories often have two command layers:

1. project-level commands such as `make dev`, `make build`, `make test`, `make deploy`
2. unit-level commands such as `pnpm --filter @scope/app test`, `go test ./cmd/api`, or `cargo test -p worker`

There are also valid cases where:

- some units expose `dev`
- some units expose only `build/test/typecheck`
- some units expose no standalone dev entry at all

If the skill does not model this explicitly, it produces misleading guidance such as implying every `apps/*` package should have a `dev` command or that all unit commands belong in the root `Makefile`.

## Decision

Add a `command surface matrix` beside the existing `deployment unit matrix`.

The deployment matrix answers:

- what gets deployed
- how it is hosted
- what its rollback boundary is

The command matrix answers:

- what the project-level unified entry is
- what each unit can actually run on its own
- which runner owns that command surface
- which expected commands are missing
- which command should be recommended to the developer first

## Model

### Project-level command surface

Project-level commands are the unified repository entry points. They are typically rooted in `Makefile`, repo-level package scripts, or equivalent orchestration commands.

Examples:

- `make dev`
- `make build`
- `make test`
- `make deploy`

### Unit-level command surface

Unit-level commands are scoped to a deployment unit or workspace package.

Examples:

- `pnpm --filter @ohrelay/core dev`
- `pnpm --filter @ohrelay/dashboard test`
- `go test ./cmd/api`
- `cargo test -p worker`

## Rules

1. Do not assume every deployment unit exposes `dev`.
2. Do not require every unit-level command to be aliased into the root `Makefile`.
3. Keep the root command contract small and project-level.
4. Preserve unit-native runners (`pnpm`, `npm`, `bun`, `uv`, `go`, `cargo`, etc.) when they already express local development or testing cleanly.
5. In monorepos, report both layers together so users can see the default repo command and the narrower per-unit command path.

## Required command matrix fields

Each row in the command surface matrix should include:

- `scope` (`project-level` or `unit-level`)
- `unit_name`
- `code_path`
- `runner`
- `available_commands`
- `missing_expected_commands`
- `recommended_entry`

## Fixture impact

Static fixtures need to describe command expectations, not only deployment expectations.

Fixture metadata should therefore gain fields for:

- expected project-level commands
- expected unit-level commands
- expected command recommendation

At least one monorepo fixture should model the realistic case where one unit has `dev` and another does not.

## Verification impact

Static validation should check:

- the new metadata fields exist and remain ordered
- fixture package manifests that are meant to model unit-level commands actually contain representative scripts
- monorepo fixtures explicitly cover uneven script availability across units
