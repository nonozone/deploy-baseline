# Production Env Sync Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a non-destructive env sync path so `app.prod.env` can absorb new keys from `app.prod.env.example` without overwriting existing values and while preserving example-style grouping when possible.

**Architecture:** Add a dedicated deploy-side sync script, expose it through `make env-sync`, invoke it from setup, and make preflight detect env drift with a clear remediation path. Mirror the same behavior in the skill-bundled template and document the workflow.

**Tech Stack:** Bash, Make, Markdown

---

## Chunk 1: Sync Behavior

### Task 1: Add env sync command and script

**Files:**
- Modify: `template/Makefile`
- Create: `template/deploy/scripts/env-sync.sh`
- Modify: `template/scripts/setup.sh`
- Modify: `skills/deploy-baseline-kit/assets/template/Makefile`
- Create: `skills/deploy-baseline-kit/assets/template/deploy/scripts/env-sync.sh`
- Modify: `skills/deploy-baseline-kit/assets/template/scripts/setup.sh`

- [ ] Add `make env-sync`.
- [ ] Implement non-destructive grouped insertion syncing from `app.prod.env.example` to `app.prod.env`.
- [ ] Make `setup` call the same sync logic.

### Task 2: Detect env drift during deploy checks

**Files:**
- Modify: `template/deploy/scripts/preflight.sh`
- Modify: `skills/deploy-baseline-kit/assets/template/deploy/scripts/preflight.sh`

- [ ] Detect missing keys that exist in the example but not in the real file.
- [ ] Fail with a clear instruction to run `make env-sync`.
- [ ] Keep deploy-check non-mutating.

## Chunk 2: Docs And Skill Guidance

### Task 3: Update docs and rules

**Files:**
- Modify: `README.md`
- Modify: `docs/baseline-standard.md`
- Modify: `docs/deployment-sop.md`
- Modify: `docs/deploy-baseline-kit.md`
- Modify: `template/README.md`
- Modify: `template/deploy/README.md`
- Modify: `skills/deploy-baseline-kit/SKILL.md`
- Modify: `skills/deploy-baseline-kit/references/transformation-rules.md`
- Modify: `skills/deploy-baseline-kit/references/verification.md`
- Modify: `skills/deploy-baseline-kit/assets/template/README.md`
- Modify: `skills/deploy-baseline-kit/assets/template/deploy/README.md`

- [ ] Document `make env-sync` as a helper command.
- [ ] Explain the difference between example structure and real production env values.
- [ ] State that sync inserts missing keys by example-group order when possible and never overwrites existing values.

## Chunk 3: Verification

### Task 4: Run repository verification

**Files:**
- Verify: `template/deploy/scripts/env-sync.sh`
- Verify: `skills/deploy-baseline-kit/assets/template/deploy/scripts/env-sync.sh`
- Verify: `template/deploy/scripts/preflight.sh`

- [ ] Run `make verify-baseline`.
- [ ] Run `git diff --check`.
- [ ] Confirm template and skill-bundled copies stay aligned.
