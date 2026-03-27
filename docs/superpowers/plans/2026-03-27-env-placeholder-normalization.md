# Env Placeholder Normalization Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Normalize deploy env example placeholder values and keep preflight/documentation behavior aligned with the new convention.

**Architecture:** Update the deploy env examples first, then align the validation layer (`preflight.sh`) and the written guidance so one placeholder policy is visible across templates, skill assets, and docs.

**Tech Stack:** Markdown, shell templates, env examples

---

## Chunk 1: Normalize Example Files

### Task 1: Update deploy env examples

**Files:**
- Modify: `template/deploy/env/app.env.example`
- Modify: `template/deploy/env/app.prod.env.example`
- Modify: `skills/deploy-baseline-kit/assets/template/deploy/env/app.env.example`
- Modify: `skills/deploy-baseline-kit/assets/template/deploy/env/app.prod.env.example`

- [ ] Convert sensitive placeholders to `replace-me`.
- [ ] Preserve concrete runnable defaults for non-sensitive values.
- [ ] Keep image tag placeholders on `replace-with-git-sha`.
- [ ] Keep template and skill-bundled copies identical.

## Chunk 2: Align Validation And Docs

### Task 2: Update preflight checks

**Files:**
- Modify: `template/deploy/scripts/preflight.sh`
- Modify: `skills/deploy-baseline-kit/assets/template/deploy/scripts/preflight.sh`

- [ ] Reject the normalized sensitive placeholder values.
- [ ] Keep backward-compatible rejection for legacy `change-me` placeholders.

### Task 3: Update docs and skill guidance

**Files:**
- Modify: `docs/baseline-standard.md`
- Modify: `template/README.md`
- Modify: `skills/deploy-baseline-kit/assets/template/README.md`
- Modify: `skills/deploy-baseline-kit/references/transformation-rules.md`

- [ ] Document the placeholder policy explicitly.
- [ ] Explain which values should stay concrete and which must be replaced.

## Chunk 3: Verification

### Task 4: Run repository verification

**Files:**
- Verify: `template/deploy/env/app.env.example`
- Verify: `skills/deploy-baseline-kit/assets/template/deploy/env/app.env.example`
- Verify: `template/deploy/scripts/preflight.sh`

- [ ] Run `make verify-baseline`.
- [ ] Run `git diff --check`.
- [ ] Confirm duplicated template and skill files remain identical.
