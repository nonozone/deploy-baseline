# Monorepo Mixed Deployment Surfaces Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor `deploy-baseline-kit` so its analysis, planning output, confirmation gate, and verification model are based on deployment units and mixed hosting surfaces rather than a single-project deployment assumption.

**Architecture:** Update the skill’s main workflow and reference docs to introduce a deployment unit matrix as the primary planning structure. Phase 1 focuses on the skill’s reasoning model, output contract, confirmation semantics, and verification selection rules. It intentionally stops short of full per-unit generation logic so the mental model and documentation become stable before execution behavior is expanded in a later phase.

**Tech Stack:** Markdown, skill docs, repository docs

---

## File Structure

### New files

- `docs/superpowers/specs/2026-03-26-monorepo-mixed-deployment-surfaces-design.md`
  Purpose: approved design source for the monorepo mixed deployment surfaces model.
- `docs/superpowers/plans/2026-03-26-monorepo-mixed-deployment-surfaces-phase1.md`
  Purpose: implementation plan for the first skill refactor phase.

### Modified files

- `skills/deploy-baseline-kit/SKILL.md`
  Purpose: update top-level workflow, confirmation gate, execution rules, and required planning output to use deployment units and mixed hosting surfaces.
- `skills/deploy-baseline-kit/references/project-analysis.md`
  Purpose: replace repo-global classification assumptions with deployment unit discovery and deployable surface inventory rules.
- `skills/deploy-baseline-kit/references/mode-detection.md`
  Purpose: clarify that mode detection may vary by deployment unit and that repo-wide mode assumptions are insufficient in monorepos.
- `skills/deploy-baseline-kit/references/transformation-rules.md`
  Purpose: define baseline action handling for self-hosted, static-hosted, provider-managed, and document-only deployment units.
- `skills/deploy-baseline-kit/references/verification.md`
  Purpose: split verification rules by deployment unit type instead of assuming Compose-centric validation only.
- `docs/deploy-baseline-kit.md`
  Purpose: update public behavior notes so the repo docs match the new multi-surface planning model.
- `README.md`
  Purpose: optionally add one short note if needed so the repo-level description of the skill stays aligned with the new model.

## Chunk 1: Skill Workflow And Output Contract

### Task 1: Refactor the skill’s top-level workflow around deployment units

**Files:**
- Modify: `skills/deploy-baseline-kit/SKILL.md`
- Modify: `docs/deploy-baseline-kit.md`
- Test: `skills/deploy-baseline-kit/SKILL.md`

- [ ] **Step 1: Update the skill overview and workflow**

Revise `skills/deploy-baseline-kit/SKILL.md` so the workflow becomes:

1. resolve repository root
2. detect deployable surfaces
3. build deployment unit matrix
4. determine recommended baseline action per unit
5. emit one confirmation message with the matrix
6. execute per-unit handling after confirmation
7. run per-unit verification
8. report per-unit outcomes

Keep the “one confirmation only” design, but remove language that assumes the entire repository has one deploy surface.

- [ ] **Step 2: Update required planning output**

Change the `Required Planning Output` section in `skills/deploy-baseline-kit/SKILL.md` so it always includes:

- repository root
- deployment unit matrix
- per-unit hosting mode
- per-unit rollback unit
- per-unit baseline action
- current assets by unit
- unresolved low-confidence fields
- verification plan by unit

Keep room for single-project repos by treating them as a one-row matrix.

- [ ] **Step 3: Align the public behavior doc**

Update `docs/deploy-baseline-kit.md` so its behavior description matches the new workflow:

- root detection remains
- project scanning becomes deployment surface discovery
- single confirmation remains
- results are reported per deployment unit

- [ ] **Step 4: Verify the edited docs read cleanly**

Run:

```bash
sed -n '1,260p' skills/deploy-baseline-kit/SKILL.md
sed -n '1,260p' docs/deploy-baseline-kit.md
```

Expected:

- no remaining top-level wording that implies the repository must converge as one deployment surface
- clear statement that single-project repos are a special case of the deployment matrix

- [ ] **Step 5: Commit**

```bash
git add skills/deploy-baseline-kit/SKILL.md docs/deploy-baseline-kit.md
git commit -m "docs: refactor deploy baseline skill workflow for deployment units"
```

### Task 2: Redesign the confirmation gate as a single matrix-aware confirmation

**Files:**
- Modify: `skills/deploy-baseline-kit/SKILL.md`
- Modify: `docs/deploy-baseline-kit.md`
- Test: `skills/deploy-baseline-kit/SKILL.md`

- [ ] **Step 1: Replace repo-global confirmation wording**

Edit `skills/deploy-baseline-kit/SKILL.md` so the confirmation gate explicitly supports:

- one confirmation message
- multiple deployment units
- per-unit handling recommendations
- unresolved low-confidence fields inside that same message

The confirmation gate must no longer imply a single repository-wide choice between conservative and forced convergence.

- [ ] **Step 2: Document per-unit confirmation examples**

Add examples such as:

- `core: conservative self-hosted convergence`
- `www: external static hosting, do not Dockerize`
- `worker: provider-managed, document deploy command only`

These examples should appear in the public behavior doc or the skill body, whichever gives the clearest operator-facing guidance.

- [ ] **Step 3: Verify wording consistency**

Run:

```bash
rg -n "conservative|forced|single confirmation|confirmation" skills/deploy-baseline-kit/SKILL.md docs/deploy-baseline-kit.md
```

Expected:

- conservative vs forced is still available where relevant
- but only as a per-unit action within one confirmation, not as the only repo-level decision

- [ ] **Step 4: Commit**

```bash
git add skills/deploy-baseline-kit/SKILL.md docs/deploy-baseline-kit.md
git commit -m "docs: redesign deploy baseline confirmation around deployment units"
```

## Chunk 2: Reference Model Shift

### Task 3: Replace project analysis with deployable surface discovery

**Files:**
- Modify: `skills/deploy-baseline-kit/references/project-analysis.md`
- Test: `skills/deploy-baseline-kit/references/project-analysis.md`

- [ ] **Step 1: Rewrite inventory guidance**

Refactor `project-analysis.md` so it instructs the skill to inventory:

- deployable code paths
- public surfaces
- hosting signals
- runtime manifests
- existing deploy commands
- ownership boundaries

Do not let the reference stop at repo-global deployment assets only.

- [ ] **Step 2: Replace the current three-way classification model**

Preserve the useful maturity categories:

- empty or near-empty
- lightweight existing
- heavy existing deployment

But apply them at the deployment-unit level where appropriate.

Also add a rule that:

- same repository does not imply same deploy target

- [ ] **Step 3: Add deployment unit matrix output requirements**

Document the required matrix fields:

- public surface
- code path
- unit type
- runtime
- hosting mode
- statefulness
- deploy command
- rollback unit
- baseline action

- [ ] **Step 4: Verify the new reference**

Run:

```bash
sed -n '1,260p' skills/deploy-baseline-kit/references/project-analysis.md
```

Expected:

- analysis guidance is now matrix-first rather than repo-first
- single-project repositories are still understandable as a trivial one-unit case

- [ ] **Step 5: Commit**

```bash
git add skills/deploy-baseline-kit/references/project-analysis.md
git commit -m "docs: make project analysis deployment-surface aware"
```

### Task 4: Update mode detection and transformation rules for mixed hosting

**Files:**
- Modify: `skills/deploy-baseline-kit/references/mode-detection.md`
- Modify: `skills/deploy-baseline-kit/references/transformation-rules.md`
- Test: `skills/deploy-baseline-kit/references/mode-detection.md`
- Test: `skills/deploy-baseline-kit/references/transformation-rules.md`

- [ ] **Step 1: Update mode detection**

Refactor `mode-detection.md` so it states:

- deployment mode may vary by unit
- monorepos may contain mixed hosting modes
- static sites and provider-managed surfaces should not be folded into repo-wide Docker assumptions

- [ ] **Step 2: Introduce baseline action handling**

Update `transformation-rules.md` to define the behavior of:

- `converge-self-hosted`
- `exclude-from-compose`
- `provider-managed`
- `document-only`

Make it explicit that:

- static sites should not be Dockerized by default
- provider-managed units are first-class deployment surfaces
- same repo does not imply same deploy directory or same convergence path

- [ ] **Step 3: Add external static and provider-specific rules**

Document the minimum expected handling for:

- external static hosting surfaces
- external platform assets such as Cloudflare Workers

This should include:

- build or deploy command expectations
- manifest or output-dir expectations
- secrets and ownership boundary notes

- [ ] **Step 4: Verify both references**

Run:

```bash
sed -n '1,240p' skills/deploy-baseline-kit/references/mode-detection.md
sed -n '1,320p' skills/deploy-baseline-kit/references/transformation-rules.md
```

Expected:

- mixed hosting is explicitly supported
- Compose is treated as one possible convergence path, not the only deploy baseline outcome

- [ ] **Step 5: Commit**

```bash
git add skills/deploy-baseline-kit/references/mode-detection.md skills/deploy-baseline-kit/references/transformation-rules.md
git commit -m "docs: add mixed-hosting baseline actions to deploy rules"
```

## Chunk 3: Verification And Repo-Level Alignment

### Task 5: Split verification by deployment unit type

**Files:**
- Modify: `skills/deploy-baseline-kit/references/verification.md`
- Modify: `docs/deploy-baseline-kit.md`
- Test: `skills/deploy-baseline-kit/references/verification.md`

- [ ] **Step 1: Replace Compose-only framing**

Update `verification.md` so verification is chosen per deployment unit type:

- self-hosted service
- static site
- external platform

### Self-hosted minimum checks

- `bash -n`
- `docker compose config`
- `make help`
- build, test, or typecheck if present
- healthcheck presence
- env existence
- rollback boundary notes

### Static site minimum checks

- build command
- output directory existence
- route or base path assumptions
- env contract
- hosting notes

### External platform minimum checks

- manifest or config existence
- deploy command presence
- required secrets documented
- optional lint or dry-run command if available
- rollback inclusion or exclusion documented

- [ ] **Step 2: Update public behavior wording**

Ensure `docs/deploy-baseline-kit.md` no longer implies that “not in Compose” means “outside the deployment baseline”.

- [ ] **Step 3: Verify the new verification model**

Run:

```bash
sed -n '1,260p' skills/deploy-baseline-kit/references/verification.md
sed -n '1,260p' docs/deploy-baseline-kit.md
```

Expected:

- verification rules are clearly split by deployment unit type
- static and provider-managed surfaces are explicitly recognized

- [ ] **Step 4: Commit**

```bash
git add skills/deploy-baseline-kit/references/verification.md docs/deploy-baseline-kit.md
git commit -m "docs: split deploy baseline verification by deployment unit type"
```

### Task 6: Align repo-level documentation and validate consistency

**Files:**
- Modify: `README.md`
- Test: `README.md`
- Test: `skills/deploy-baseline-kit/SKILL.md`
- Test: `docs/deploy-baseline-kit.md`

- [ ] **Step 1: Update README only if necessary**

Add a short note only if needed so the repo-level description of `deploy-baseline-kit` no longer reads like a single-project-only skill.

Keep this small and avoid turning README into a second spec.

- [ ] **Step 2: Run final consistency checks**

Run:

```bash
rg -n "single project|single deploy|single deployment|whole repository|same repo" README.md docs/deploy-baseline-kit.md skills/deploy-baseline-kit/SKILL.md skills/deploy-baseline-kit/references/project-analysis.md skills/deploy-baseline-kit/references/mode-detection.md skills/deploy-baseline-kit/references/transformation-rules.md skills/deploy-baseline-kit/references/verification.md
```

Expected:

- no contradictory wording remains
- same-repo vs same-deploy-target distinction is stated where needed

- [ ] **Step 3: Run final plan-scope verification**

Run:

```bash
git diff --check
```

Expected:

- no patch formatting issues

- [ ] **Step 4: Commit**

```bash
git add README.md docs/deploy-baseline-kit.md skills/deploy-baseline-kit/SKILL.md skills/deploy-baseline-kit/references/project-analysis.md skills/deploy-baseline-kit/references/mode-detection.md skills/deploy-baseline-kit/references/transformation-rules.md skills/deploy-baseline-kit/references/verification.md
git commit -m "docs: align deploy baseline skill with mixed deployment surfaces"
```

## Execution Handoff

After this plan is implemented, the next slice should focus on phase 2 execution behavior:

- per-unit convergence behavior
- per-unit document generation
- per-unit result reporting
- more realistic monorepo examples or fixtures if needed
