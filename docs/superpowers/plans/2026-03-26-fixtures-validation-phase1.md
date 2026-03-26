# Fixtures Validation Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first in-repo fixture validation layer for `deploy-baseline`, covering fixture scaffolding, metadata, documentation, and a static verification entrypoint.

**Architecture:** Add a repo-level `fixtures/` tree that separates lightweight static fixtures from future runnable fixtures, describe each fixture with a fixed `fixture.md` contract, and validate that contract through a dedicated shell script plus repo-level Make targets. Keep phase 1 intentionally narrow: no runtime fixture execution yet, only static coverage and a stable verification surface for later expansion.

**Tech Stack:** Markdown, Bash, GNU Make, ripgrep

---

## File Structure

### New files

- `fixtures/README.md`
  Purpose: explain the fixture taxonomy, directory rules, metadata contract, and validation scope.
- `fixtures/empty-project/fixture.md`
  Purpose: metadata for the empty-project static fixture.
- `fixtures/lightweight-existing/fixture.md`
  Purpose: metadata for the lightweight existing-project static fixture.
- `fixtures/lightweight-existing/app/main.sh`
  Purpose: minimal application anchor for lightweight project detection.
- `fixtures/lightweight-existing/.env.example`
  Purpose: partial env anchor for lightweight project detection.
- `fixtures/heavy-existing-deploy/fixture.md`
  Purpose: metadata for the heavy existing deploy static fixture.
- `fixtures/heavy-existing-deploy/Makefile`
  Purpose: existing deployment-surface anchor for heavy-project detection.
- `fixtures/heavy-existing-deploy/docker-compose.yml`
  Purpose: base Compose anchor for heavy-project detection.
- `fixtures/heavy-existing-deploy/docker-compose.prod.yml`
  Purpose: production Compose anchor for heavy-project detection.
- `fixtures/heavy-existing-deploy/deploy/README.md`
  Purpose: existing deployment-doc anchor for heavy-project detection.
- `fixtures/frontend-backend-split/fixture.md`
  Purpose: metadata for the frontend/backend split static fixture.
- `fixtures/frontend-backend-split/backend/package.json`
  Purpose: backend application anchor for hybrid-mode detection.
- `fixtures/frontend-backend-split/frontend/package.json`
  Purpose: frontend application anchor for split-project detection.
- `fixtures/monorepo-subproject/fixture.md`
  Purpose: metadata for the monorepo subproject static fixture.
- `fixtures/monorepo-subproject/package.json`
  Purpose: monorepo root anchor.
- `fixtures/monorepo-subproject/apps/api/package.json`
  Purpose: target subproject anchor.
- `fixtures/monorepo-subproject/apps/web/package.json`
  Purpose: sibling subproject anchor.
- `fixtures/monorepo-subproject/packages/shared/README.md`
  Purpose: shared workspace anchor.
- `fixtures/mysql-compare/fixture.md`
  Purpose: metadata for the MySQL compare static fixture.
- `fixtures/mysql-compare/docker-compose.yml`
  Purpose: non-PostgreSQL database anchor for detection.
- `scripts/verify-fixtures-static.sh`
  Purpose: verify fixture directory completeness and `fixture.md` field contract.
- `Makefile`
  Purpose: repo-level verification entrypoints for fixture validation.

### Modified files

- `README.md`
  Purpose: document the new `fixtures/` area and repo-level verification commands.
- `docs/roadmap-v1.1.md`
  Purpose: mark the phase-1 fixture scaffolding task as started or clarify its implementation boundary.

## Chunk 1: Fixture Scaffolding And Metadata

### Task 1: Add the fixture taxonomy documentation

**Files:**
- Create: `fixtures/README.md`
- Modify: `README.md`
- Test: `fixtures/README.md`

- [ ] **Step 1: Write the fixture-area documentation**

Create `fixtures/README.md` with:

```md
# Fixtures

This directory contains sample project fixtures used to validate `deploy-baseline-kit`
classification and future baseline verification commands.

## Layout

- top-level fixture directories are static fixtures
- `runnable/` is reserved for executable fixtures

## Metadata contract

Each fixture must provide `fixture.md` with these keys:
- `name`
- `scenario`
- `expected_root`
- `expected_classification`
- `expected_mode`
- `expected_database`
- `support_level`
- `expected_recommendation`
- `verification_level`
- `notes`
```

- [ ] **Step 2: Update the main README to point to fixtures**

Edit `README.md` to add:

- the `fixtures/` directory to the repository layout
- a short paragraph in the Chinese and English sections describing fixture purpose
- a mention of repo-level verification commands that will cover fixture validation

- [ ] **Step 3: Verify the fixture docs read cleanly**

Run: `sed -n '1,220p' fixtures/README.md`
Expected: fixture layout, metadata contract, and validation purpose are present and consistent with the spec.

- [ ] **Step 4: Commit**

```bash
git add fixtures/README.md README.md
git commit -m "docs: add fixtures area documentation"
```

### Task 2: Scaffold the static fixture directories and metadata

**Files:**
- Create: `fixtures/empty-project/fixture.md`
- Create: `fixtures/lightweight-existing/fixture.md`
- Create: `fixtures/lightweight-existing/app/main.sh`
- Create: `fixtures/lightweight-existing/.env.example`
- Create: `fixtures/heavy-existing-deploy/fixture.md`
- Create: `fixtures/heavy-existing-deploy/Makefile`
- Create: `fixtures/heavy-existing-deploy/docker-compose.yml`
- Create: `fixtures/heavy-existing-deploy/docker-compose.prod.yml`
- Create: `fixtures/heavy-existing-deploy/deploy/README.md`
- Create: `fixtures/frontend-backend-split/fixture.md`
- Create: `fixtures/frontend-backend-split/backend/package.json`
- Create: `fixtures/frontend-backend-split/frontend/package.json`
- Create: `fixtures/monorepo-subproject/fixture.md`
- Create: `fixtures/monorepo-subproject/package.json`
- Create: `fixtures/monorepo-subproject/apps/api/package.json`
- Create: `fixtures/monorepo-subproject/apps/web/package.json`
- Create: `fixtures/monorepo-subproject/packages/shared/README.md`
- Create: `fixtures/mysql-compare/fixture.md`
- Create: `fixtures/mysql-compare/docker-compose.yml`
- Test: `fixtures/**/*.md`

- [ ] **Step 1: Write the empty-project fixture metadata**

Create `fixtures/empty-project/fixture.md`:

```md
# Fixture Metadata

- name: empty-project
- scenario: empty project directory
- expected_root: .
- expected_classification: empty project
- expected_mode: unknown
- expected_database: unknown
- support_level: stable
- expected_recommendation: generate baseline skeleton
- verification_level: static
- notes: contains no deployment assets and should be treated as a near-empty project
```

- [ ] **Step 2: Write the lightweight-existing fixture metadata and anchors**

Create `fixtures/lightweight-existing/fixture.md`:

```md
# Fixture Metadata

- name: lightweight-existing
- scenario: lightweight existing project
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: hybrid development
- expected_database: postgresql
- support_level: stable
- expected_recommendation: conservative convergence
- verification_level: static
- notes: contains app code, partial env, and incomplete deploy assets
```

Create `fixtures/lightweight-existing/app/main.sh`:

```bash
#!/bin/bash
echo "fixture app"
```

Create `fixtures/lightweight-existing/.env.example`:

```dotenv
APP_PORT=3000
DATABASE_URL=postgresql://app:app@db:5432/app
```

- [ ] **Step 3: Write the heavy-existing-deploy fixture metadata and anchors**

Create `fixtures/heavy-existing-deploy/fixture.md`:

```md
# Fixture Metadata

- name: heavy-existing-deploy
- scenario: heavy existing deployment project
- expected_root: .
- expected_classification: heavy existing deployment project
- expected_mode: docker
- expected_database: postgresql
- support_level: stable
- expected_recommendation: choose conservative or forced convergence
- verification_level: static
- notes: contains make targets, multiple compose files, and existing deploy docs
```

Create `fixtures/heavy-existing-deploy/Makefile`:

```make
help:
	@echo "existing help"

deploy:
	@echo "existing deploy"
```

Create `fixtures/heavy-existing-deploy/docker-compose.yml`:

```yaml
services:
  app:
    image: example/app:dev
```

Create `fixtures/heavy-existing-deploy/docker-compose.prod.yml`:

```yaml
services:
  app:
    image: example/app:prod
  db:
    image: postgres:17-alpine
```

Create `fixtures/heavy-existing-deploy/deploy/README.md`:

```md
# Existing Deploy

This fixture simulates a project with an existing deployment surface.
```

- [ ] **Step 4: Write the frontend-backend-split fixture metadata and anchors**

Create `fixtures/frontend-backend-split/fixture.md`:

```md
# Fixture Metadata

- name: frontend-backend-split
- scenario: frontend backend split project
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: hybrid development
- expected_database: postgresql
- support_level: stable
- expected_recommendation: conservative convergence
- verification_level: static
- notes: frontend and backend are separate directories with backend-first deploy baseline focus
```

Create `fixtures/frontend-backend-split/backend/package.json`:

```json
{
  "name": "fixture-backend",
  "private": true
}
```

Create `fixtures/frontend-backend-split/frontend/package.json`:

```json
{
  "name": "fixture-frontend",
  "private": true
}
```

- [ ] **Step 5: Write the monorepo-subproject fixture metadata and anchors**

Create `fixtures/monorepo-subproject/fixture.md`:

```md
# Fixture Metadata

- name: monorepo-subproject
- scenario: monorepo subproject entry
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: hybrid development
- expected_database: postgresql
- support_level: baseline
- expected_recommendation: confirm root and scope before convergence
- verification_level: static
- notes: contains multiple apps and a shared package to exercise root detection boundaries
```

Create `fixtures/monorepo-subproject/package.json`:

```json
{
  "name": "fixture-monorepo",
  "private": true,
  "workspaces": ["apps/*", "packages/*"]
}
```

Create `fixtures/monorepo-subproject/apps/api/package.json`:

```json
{
  "name": "fixture-api",
  "private": true
}
```

Create `fixtures/monorepo-subproject/apps/web/package.json`:

```json
{
  "name": "fixture-web",
  "private": true
}
```

Create `fixtures/monorepo-subproject/packages/shared/README.md`:

```md
# Shared Package
```

- [ ] **Step 6: Write the mysql-compare fixture metadata and anchors**

Create `fixtures/mysql-compare/fixture.md`:

```md
# Fixture Metadata

- name: mysql-compare
- scenario: mysql comparison project
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: docker
- expected_database: mysql
- support_level: experimental
- expected_recommendation: conservative convergence with explicit database confirmation
- verification_level: static
- notes: validates that non-postgresql projects are detected and described conservatively
```

Create `fixtures/mysql-compare/docker-compose.yml`:

```yaml
services:
  db:
    image: mysql:8.4
    environment:
      MYSQL_DATABASE: app
      MYSQL_USER: app
      MYSQL_PASSWORD: app
      MYSQL_ROOT_PASSWORD: root
```

- [ ] **Step 7: Verify all fixture metadata files exist**

Run: `find fixtures -name fixture.md | sort`
Expected:

```text
fixtures/empty-project/fixture.md
fixtures/frontend-backend-split/fixture.md
fixtures/heavy-existing-deploy/fixture.md
fixtures/lightweight-existing/fixture.md
fixtures/monorepo-subproject/fixture.md
fixtures/mysql-compare/fixture.md
```

- [ ] **Step 8: Commit**

```bash
git add fixtures
git commit -m "feat: scaffold static validation fixtures"
```

## Chunk 2: Static Verification Entry Point

### Task 3: Add the static fixture verification script

**Files:**
- Create: `scripts/verify-fixtures-static.sh`
- Test: `scripts/verify-fixtures-static.sh`

- [ ] **Step 1: Write the verification script**

Create `scripts/verify-fixtures-static.sh`:

```bash
#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURES_DIR="$ROOT_DIR/fixtures"

required_fields=(
  "name"
  "scenario"
  "expected_root"
  "expected_classification"
  "expected_mode"
  "expected_database"
  "support_level"
  "expected_recommendation"
  "verification_level"
  "notes"
)

expected_fixtures=(
  "empty-project"
  "lightweight-existing"
  "heavy-existing-deploy"
  "frontend-backend-split"
  "monorepo-subproject"
  "mysql-compare"
)

for fixture in "${expected_fixtures[@]}"; do
  file="$FIXTURES_DIR/$fixture/fixture.md"
  [[ -f "$file" ]] || { echo "missing fixture metadata: $file" >&2; exit 1; }
  for field in "${required_fields[@]}"; do
    rg -q "^- ${field}: " "$file" || { echo "missing field '${field}' in $file" >&2; exit 1; }
  done
done

echo "static fixture metadata verification passed"
```

- [ ] **Step 2: Run shell syntax verification**

Run: `bash -n scripts/verify-fixtures-static.sh`
Expected: exit code 0 with no output.

- [ ] **Step 3: Run the verification script**

Run: `bash scripts/verify-fixtures-static.sh`
Expected: `static fixture metadata verification passed`

- [ ] **Step 4: Commit**

```bash
git add scripts/verify-fixtures-static.sh
git commit -m "feat: add static fixture verification script"
```

### Task 4: Add repo-level Make targets for fixture verification

**Files:**
- Create: `Makefile`
- Modify: `README.md`
- Modify: `docs/roadmap-v1.1.md`
- Test: `Makefile`

- [ ] **Step 1: Create the repo Makefile**

Create `Makefile`:

```make
SHELL := /bin/bash

.PHONY: help verify-fixtures-static verify-baseline

help: ## Show repository maintenance commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-24s %s\n", $$1, $$2}'

verify-fixtures-static: ## Verify static fixture metadata and layout
	bash scripts/verify-fixtures-static.sh

verify-baseline: verify-fixtures-static ## Run baseline repository verification
```

- [ ] **Step 2: Document the new verification commands**

Edit `README.md` to mention:

- `make verify-fixtures-static`
- `make verify-baseline`
- phase 1 currently validates static fixtures only

Edit `docs/roadmap-v1.1.md` to reflect:

- phase 1 scaffolding and static validation are now the active first slice

- [ ] **Step 3: Verify the Make targets**

Run: `make help`
Expected: output includes `verify-fixtures-static` and `verify-baseline`.

Run: `make verify-fixtures-static`
Expected: `static fixture metadata verification passed`

- [ ] **Step 4: Commit**

```bash
git add Makefile README.md docs/roadmap-v1.1.md
git commit -m "feat: add fixture verification make targets"
```

## Chunk 3: Completion Verification And Handoff

### Task 5: Run final phase-1 verification and summarize follow-up

**Files:**
- Modify: `README.md`
- Modify: `docs/roadmap-v1.1.md`
- Test: `Makefile`

- [ ] **Step 1: Run the full phase-1 verification commands**

Run: `git diff --check`
Expected: no output.

Run: `bash -n scripts/verify-fixtures-static.sh`
Expected: exit code 0.

Run: `make verify-baseline`
Expected: static fixture verification passes.

- [ ] **Step 2: Re-read the spec and confirm scope match**

Read:

- `docs/superpowers/specs/2026-03-26-fixtures-validation-design.md`

Expected: implemented scope matches phase 1 only and does not accidentally include runnable fixture execution.

- [ ] **Step 3: Commit the final integrated state**

```bash
git add Makefile README.md docs/roadmap-v1.1.md fixtures scripts/verify-fixtures-static.sh
git commit -m "feat: add phase 1 fixture validation baseline"
```

- [ ] **Step 4: Prepare the next slice**

Document the next implementation target in the final handoff:

- `fixtures/runnable/pg-new-project/`
- `fixtures/runnable/pg-existing-project/`
- `make verify-fixtures-runnable`

