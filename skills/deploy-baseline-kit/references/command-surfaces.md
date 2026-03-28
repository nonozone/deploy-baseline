# Command Surfaces

Use this reference when the repository has more than one command layer, especially in monorepos or multi-unit repos.

## Two command layers

### Project-level

This is the unified repository entry surface.

Examples:

- `make dev`
- `make build`
- `make test`
- `make deploy`

This layer should stay small and stable.

### Unit-level

This is the narrower command surface for a specific app, package, worker, or service.

Examples:

- `pnpm --filter @scope/core dev`
- `pnpm --filter @scope/dashboard test`
- `go test ./cmd/api`
- `cargo test -p worker`

## Hard rules

- Do not assume every unit exposes `dev`.
- Do not force every unit command into the root `Makefile`.
- Preserve unit-native runners when they already fit the repo well.
- The root `Makefile` should express project-level defaults, not every possible subcommand in the repository.

## Required command surface matrix

Before confirmation, report a command surface matrix beside the deployment unit matrix.

Each command matrix row should include:

- `scope` (`project-level` or `unit-level`)
- `unit_name`
- `code_path`
- `runner`
- `available_commands`
- `missing_expected_commands`
- `recommended_entry`

## Recommendation rules

- If a root `Makefile` exists, treat its stable targets as project-level commands.
- If workspace packages or service directories expose their own scripts, treat them as unit-level commands.
- If a unit has `build` and `test` but no `dev`, report that plainly instead of inventing one.
- If there is no project-level command layer yet, recommend converging on it without erasing unit-native scripts.
