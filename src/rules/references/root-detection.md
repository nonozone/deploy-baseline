# Root Detection

Use this reference when the developer may run the skill from a subdirectory.

## Goal

Find the most likely project root before you inspect deployment assets or plan file edits.

## Preferred method

Run `scripts/detect-root.sh <start-dir>` first.

If the script returns one path with strong evidence, use it.

## Signals

Score directories higher when they contain several of these anchors:

- `.git/`
- `package.json`
- `pyproject.toml`
- `go.mod`
- `Cargo.toml`
- `Dockerfile`
- `Makefile`
- `README.md`
- `docker-compose.yml`

Favor the highest directory that still looks like one coherent app root.

## Escalate in the confirmation gate

Do not assume a single root when you find:

- a monorepo with several app packages
- separate frontend and backend roots
- multiple sibling Compose or deploy stacks

In that case, tell the developer which root you plan to modify and include that scope in the one confirmation message.
