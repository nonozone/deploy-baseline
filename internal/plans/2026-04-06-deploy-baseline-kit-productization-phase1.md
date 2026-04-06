# Deploy Baseline Kit Productization Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure this repository into a skill-first product with one editable source tree, generated distribution assets, product-facing docs, and a baseline-first convergence contract for existing projects.

**Architecture:** Keep `skills/deploy-baseline-kit/` as the editable skill entry and install contract, introduce `src/` as the only source area for template/docs/rules, and generate `dist/deploy-baseline-kit/` as the self-contained installable package. Treat baseline convergence rules as product policy: existing projects should be normalized toward the baseline, with explicit `exceptions` instead of silent drift.

**Tech Stack:** Bash, Make, Markdown, filesystem packaging, Codex skill assets

---

## Chunk 1: Canonical Product Source

### Task 1: Establish the single-source repository layout

**Files:**
- Create: `src/template/`
- Create: `src/docs/`
- Create: `src/rules/`
- Create: `dist/.gitkeep`
- Modify: `README.md`
- Modify: `docs/README.md`
- Modify: `docs/deploy-baseline-kit.md`
- Modify: `internal/specs/2026-04-06-deploy-baseline-kit-productization-design.md`
- Modify: `skills/deploy-baseline-kit/SKILL.md`

- [ ] Create `src/template/` and move the editable baseline template tree out of `template/`.
- [ ] Create `src/docs/` for product-facing source docs that belong to the installable skill package or product site.
- [ ] Create `src/rules/` and move the editable rule/reference content there so product policy has one home.
- [ ] Introduce `dist/` as build output only and keep it empty or ignored until packaging runs.
- [ ] Update top-level docs so the repository is described as a skill product first, not a mixed template repo.

### Task 2: Reduce `skills/deploy-baseline-kit/` to skill-entry source

**Files:**
- Modify: `skills/deploy-baseline-kit/SKILL.md`
- Modify: `skills/deploy-baseline-kit/agents/openai.yaml`
- Create: `skills/deploy-baseline-kit/product.md`
- Delete or stop editing directly: `skills/deploy-baseline-kit/assets/template/` after generated replacement is in place

- [ ] Keep `skills/deploy-baseline-kit/` as the source location for the skill contract and runtime entrypoint.
- [ ] Remove the assumption that `assets/template/` is hand-maintained source.
- [ ] Point the skill and any related metadata at the new source/build model.
- [ ] Add a short product-facing `product.md` that explains installable-skill behavior and baseline-first convergence intent.

## Chunk 2: Build, Package, Install

### Task 3: Add product build and package scripts

**Files:**
- Create: `scripts/build-skill.sh`
- Create: `scripts/package-skill.sh`
- Create: `scripts/install-local-skill.sh`
- Create: `scripts/sync-template-compat.sh`
- Modify: `Makefile`

- [ ] Add `make build-skill` to generate `dist/deploy-baseline-kit/` from `skills/deploy-baseline-kit/`, `src/template/`, `src/docs/`, and `src/rules/`.
- [ ] Add `make sync-compat` to refresh compatibility directories from `src/template/`.
- [ ] Add `make package` to prepare a distributable skill directory or archive from `dist/deploy-baseline-kit/`.
- [ ] Add `make install-local` to copy the packaged skill into the local Codex skill directory for manual testing.
- [ ] Keep the commands product-oriented and short: build, verify, package, install.

### Task 4: Generate skill assets instead of co-authoring them

**Files:**
- Modify: `scripts/build-skill.sh`
- Modify: `scripts/verify-baseline.sh`
- Generated output: `dist/deploy-baseline-kit/`
- Generated output if retained for compatibility: `skills/deploy-baseline-kit/assets/template/`

- [ ] Make `build-skill.sh` copy the canonical template, docs, and rules into a self-contained package tree.
- [ ] If `skills/deploy-baseline-kit/assets/template/` remains for compatibility, generate it from `src/template/` rather than editing it by hand.
- [ ] Ensure the build pipeline fails if generated output diverges from canonical source unexpectedly.
- [ ] Keep generated output behavior deterministic so repo verification can compare source to package reliably.

## Chunk 3: Product Docs And Internal Docs

### Task 5: Rewrite the front door as a skill product

**Files:**
- Modify: `README.md`
- Modify: `docs/README.md`
- Modify: `docs/deploy-baseline-kit.md`
- Create: `src/docs/product-overview.md`
- Create: `src/docs/install.md`
- Create: `src/docs/usage.md`
- Create: `src/docs/scope.md`

- [ ] Rewrite `README.md` so it answers: what this skill is, who it is for, how to install it, how to use it, and what it supports.
- [ ] Stop presenting the repository primarily as a template library.
- [ ] Move reusable product-facing copy into `src/docs/` so packaging can include it.
- [ ] Keep scope language opinionated: the product standardizes projects toward the deploy baseline.

### Task 6: Separate internal design material from product docs

**Files:**
- Create: `internal/README.md`
- Create: `internal/specs/`
- Create: `internal/plans/`
- Move: `docs/superpowers/specs/*.md` -> `internal/specs/`
- Move: `docs/superpowers/plans/*.md` -> `internal/plans/`
- Modify: `README.md`
- Modify: `docs/README.md`

- [ ] Move design-process material out of the main product-doc path.
- [ ] Leave product-facing docs in `docs/` or `src/docs/`.
- [ ] Update references so maintainers can still find specs and plans without putting them in the user-facing navigation path.
- [ ] Keep the repository homepage focused on the skill product, not its historical design archive.

## Chunk 4: Baseline-First Behavior Contract

### Task 7: Update the skill rules to converge projects toward the baseline

**Files:**
- Modify: `skills/deploy-baseline-kit/SKILL.md`
- Create: `src/rules/convergence-policy.md`
- Create: `src/rules/exceptions.md`
- Move or rewrite from current references:
  - `skills/deploy-baseline-kit/references/transformation-rules.md`
  - `skills/deploy-baseline-kit/references/document-generation.md`
  - `skills/deploy-baseline-kit/references/verification.md`
  - `skills/deploy-baseline-kit/references/project-analysis.md`
- Generated package copies: `dist/deploy-baseline-kit/references/`

- [ ] State clearly that the default behavior is to normalize the target project toward the deploy baseline.
- [ ] Restrict deviations to explicit `exceptions`.
- [ ] Define what qualifies as a necessary exception and what should simply be converged.
- [ ] Ensure the generated package ships these rules in the exact form the installed skill will use.

### Task 8: Standardize result reporting around `exceptions`

**Files:**
- Modify: `skills/deploy-baseline-kit/SKILL.md`
- Modify: `src/rules/document-generation.md` or equivalent packaged rule file
- Modify: `docs/deploy-baseline-kit.md`
- Modify: `src/docs/usage.md`

- [ ] Add a required `exceptions` section to post-run reporting when full normalization is not possible.
- [ ] Make `exceptions` describe the drift, its cause, and remaining manual work.
- [ ] Prevent silent preservation of project-local patterns when the skill should have converged them.

## Chunk 5: Verification And Release Discipline

### Task 9: Replace historical consistency checks with product verification

**Files:**
- Modify: `scripts/verify-baseline.sh`
- Create: `scripts/verify-skill-package.sh`
- Modify: `Makefile`
- Verify: `fixtures/`

- [ ] Update verification so it checks the single-source model instead of merely checking two hand-maintained trees stay aligned.
- [ ] Add verification for generated package completeness.
- [ ] Keep fixture validation, but position it as regression coverage rather than product identity.
- [ ] Make `make verify` the primary quality gate for source integrity and package sync.

### Task 10: Run end-to-end repository verification

**Files:**
- Verify: `Makefile`
- Verify: `scripts/build-skill.sh`
- Verify: `scripts/package-skill.sh`
- Verify: `scripts/install-local-skill.sh`
- Verify: `scripts/verify-baseline.sh`
- Verify: `scripts/verify-skill-package.sh`
- Verify: `dist/deploy-baseline-kit/`

- [ ] Run `make build-skill`.
- [ ] Run `make verify`.
- [ ] Run `git diff --check`.
- [ ] Confirm the packaged skill is self-contained and installable without reading from repo-only source paths.
- [ ] Confirm no hand-edited duplicate template tree remains in the maintained source model.

## Sequencing Notes

- Do not start by rewriting behavior rules in place while the repository still has multiple source trees.
- First establish the single-source layout, then build/package generation, then docs cleanup, then rule cleanup.
- Preserve a working install path throughout the refactor by keeping `skills/deploy-baseline-kit/` valid until `dist/deploy-baseline-kit/` is proven.
- Treat generated output as disposable; regenerate instead of hand-editing it.

## Test Scenarios

- Source of truth test: editing `src/template/` and rebuilding changes the packaged skill output without requiring a second manual template edit.
- Packaging test: `dist/deploy-baseline-kit/` contains the skill contract, references, template, and product docs needed for offline installation.
- Documentation boundary test: product docs remain reachable from the repo front door while internal specs/plans move out of the user path.
- Behavior policy test: packaged skill instructions clearly prefer baseline convergence and require explicit `exceptions`.
- Verification test: `make verify` fails when generated output is stale or when the package is missing required files.

## Risks And Watchpoints

- A naive move of `template/` can break current verification and current skill installation flows if build/package scripts are not added immediately after.
- Rewriting docs before the package layout is stable can create another round of drift.
- Moving internal docs too early without redirecting references can strand maintainers.
- Keeping compatibility copies around for too long will recreate the same dual-source problem this phase is meant to remove.

Plan complete and saved to `internal/plans/2026-04-06-deploy-baseline-kit-productization-phase1.md`. Ready to execute?
