# Root Env Minimization Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the root `.env.example` a generic minimal entry surface without breaking the template's local Compose flow.

**Architecture:** Keep the root env intentionally small, move explanatory weight to docs, and add safe Compose defaults where the template previously depended on root-level database variables. Mirror every template change into the skill-bundled template to keep outputs aligned.

**Tech Stack:** Markdown, Make, Docker Compose, shell templates

---

## Chunk 1: Env Template Minimization

### Task 1: Shrink the root env examples

**Files:**
- Modify: `template/.env.example`
- Modify: `skills/deploy-baseline-kit/assets/template/.env.example`

- [ ] Replace database-heavy root env examples with a minimal generic local-entry set.
- [ ] Add a short note pointing runtime and deploy variables to `deploy/env/*.env.example`.
- [ ] Keep both copies identical.

### Task 2: Preserve template usability with Compose defaults

**Files:**
- Modify: `template/docker-compose.yml`
- Modify: `template/docker-compose.prod.yml`
- Modify: `skills/deploy-baseline-kit/assets/template/docker-compose.yml`
- Modify: `skills/deploy-baseline-kit/assets/template/docker-compose.prod.yml`

- [ ] Add safe defaults for database substitutions that were previously sourced from root `.env`.
- [ ] Keep the default values aligned with the existing PostgreSQL baseline examples.
- [ ] Keep template and skill asset copies identical.

## Chunk 2: Docs And Skill Rule Alignment

### Task 3: Update template-facing docs

**Files:**
- Modify: `template/README.md`
- Modify: `skills/deploy-baseline-kit/assets/template/README.md`
- Modify: `docs/baseline-standard.md`

- [ ] State that root `.env.example` is the first-run local entry file and should stay small.
- [ ] State that `deploy/env/*.env.example` carries fuller runtime and deploy variables.
- [ ] Keep wording aligned between repository template docs and skill-bundled template docs.

### Task 4: Update skill transformation guidance

**Files:**
- Modify: `skills/deploy-baseline-kit/references/transformation-rules.md`

- [ ] Add a rule that `.env.example` should prefer a minimal generic local entry surface.
- [ ] Keep deploy/runtime-specific values in `deploy/env/*.env.example`.

## Chunk 3: Verification

### Task 5: Run repository checks

**Files:**
- Verify: `template/.env.example`
- Verify: `skills/deploy-baseline-kit/assets/template/.env.example`
- Verify: `template/docker-compose.yml`
- Verify: `skills/deploy-baseline-kit/assets/template/docker-compose.yml`

- [ ] Run `make verify-baseline`.
- [ ] Run `git diff --check`.
- [ ] Confirm duplicated template files stay byte-identical where expected.
