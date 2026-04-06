# Command Surface Matrix Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a command surface matrix model to the deploy baseline so monorepos can expose both project-level and unit-level command paths without forcing every unit command into the root `Makefile`.

**Architecture:** Extend the skill output contract and references first, then align repository docs, then upgrade fixture metadata plus static validation so this new command-layer model has a regression surface.

**Tech Stack:** Markdown, shell, JSON fixture manifests

---

## Chunk 1: Skill And Documentation Model

### Task 1: Update the skill contract

**Files:**
- Modify: `skills/deploy-baseline-kit/SKILL.md`
- Create: `skills/deploy-baseline-kit/references/command-surfaces.md`
- Modify: `skills/deploy-baseline-kit/references/project-analysis.md`
- Modify: `skills/deploy-baseline-kit/references/transformation-rules.md`
- Modify: `skills/deploy-baseline-kit/references/verification.md`

- [ ] Add `command surface matrix` as a first-class planning output.
- [ ] Define project-level versus unit-level command handling.
- [ ] Explicitly forbid assuming every unit has a `dev` script.

### Task 2: Update repository-facing docs

**Files:**
- Modify: `README.md`
- Modify: `docs/baseline-standard.md`
- Modify: `docs/deploy-baseline-kit.md`
- Modify: `fixtures/README.md`

- [ ] Document the dual-layer command model.
- [ ] Explain when root `Makefile` should stay small.
- [ ] Explain that unit-native runners remain valid.

## Chunk 2: Fixture Contract And Static Validation

### Task 3: Expand fixture metadata

**Files:**
- Modify: `fixtures/empty-project/fixture.md`
- Modify: `fixtures/lightweight-existing/fixture.md`
- Modify: `fixtures/heavy-existing-deploy/fixture.md`
- Modify: `fixtures/frontend-backend-split/fixture.md`
- Modify: `fixtures/monorepo-subproject/fixture.md`
- Modify: `fixtures/mysql-compare/fixture.md`

- [ ] Add command-related metadata keys in a fixed order.
- [ ] Populate realistic expectations for project-level and unit-level commands.

### Task 4: Make command fixtures representative

**Files:**
- Modify: `fixtures/frontend-backend-split/backend/package.json`
- Modify: `fixtures/frontend-backend-split/frontend/package.json`
- Modify: `fixtures/monorepo-subproject/package.json`
- Modify: `fixtures/monorepo-subproject/apps/api/package.json`
- Modify: `fixtures/monorepo-subproject/apps/web/package.json`

- [ ] Add representative scripts for fixture packages.
- [ ] Ensure at least one monorepo unit intentionally lacks `dev`.

### Task 5: Upgrade static validation

**Files:**
- Modify: `scripts/verify-fixtures-static.sh`

- [ ] Validate the new metadata fields and their order.
- [ ] Validate representative fixture scripts for split and monorepo cases.

## Chunk 3: Verification

### Task 6: Run repository checks

**Files:**
- Verify: `scripts/verify-fixtures-static.sh`
- Verify: `fixtures/monorepo-subproject/fixture.md`
- Verify: `skills/deploy-baseline-kit/SKILL.md`

- [ ] Run `make verify-baseline`.
- [ ] Run `git diff --check`.
- [ ] Review the updated docs and skill files for command-model consistency.
