# `deploy-baseline-kit` Monorepo Mixed Deployment Surfaces Design

## 1. Goal

Upgrade `deploy-baseline-kit` from a single-project deployment convergence model to a deployment-surface orchestration model that can handle:

- monorepos
- multiple deployable units
- mixed hosting modes
- self-hosted and externally managed delivery surfaces in the same repository

The purpose of this design is not to weaken the baseline. It is to make the baseline correctly describe and operate on repositories where "same repo" does not mean "same deploy target".

## 2. Why The Current Model Is Not Enough

The current skill is built around a repo-level flow that assumes:

- one project root
- one main deployment surface
- one dominant deployment mode
- one convergence path

That works for:

- empty projects
- simple existing projects
- single-service repositories

But it becomes incorrect or awkward for repositories that contain:

- a self-hosted backend
- an externally hosted static site
- provider-managed worker or function surfaces
- multiple public domains or routes

In these repositories, the wrong failure mode is to treat "co-located code" as "co-deployed code".

## 3. Core Model Shift

The skill should move from:

- single-project convergence

to:

- deployment surface matrix orchestration

This means the skill must first identify all deployable surfaces, then decide which baseline path applies to each one.

Under this model, a single-project repository is just a special case where the deployment matrix has one row.

## 4. Core Concepts

### 4.1 Repository Root

The repository root answers:

- where the codebase boundary is

It does not by itself define:

- the deploy target
- the rollout unit
- the rollback unit

### 4.2 Deployment Unit

A deployment unit is any code surface that can be independently:

- planned
- deployed
- rolled out
- rolled back
- documented

Examples:

- `apps/core`
- `apps/www`
- `apps/worker`

### 4.3 Public Surface

A public surface is the externally visible entry point mapped to a deployment unit.

Examples:

- root domain
- subdomain
- API hostname
- worker route
- internal but separately deployed SMTP surface

### 4.4 Hosting Mode

Hosting mode describes how the deployment unit is delivered.

Recommended canonical values:

- `self-hosted`
- `external-static-hosting`
- `external-platform`

### 4.5 Rollout / Rollback Unit

The rollout or rollback unit is the actual boundary used to release or restore a deployment surface.

It may be:

- git ref
- image tag
- provider release
- manual restore boundary

It must not be inferred automatically from repository shape alone.

## 5. Hard Rules

These rules should become non-optional skill behavior.

- In monorepos, detect and list all deployable surfaces before choosing a baseline path.
- Do not assume a single deploy strategy for the whole repository.
- Same repository does not imply same hosting target.
- Same repository does not imply same rollout unit.
- Same repository does not imply same rollback unit.
- Branch strategy is independent from hosting strategy.
- For static marketing or static export sites, prefer external static hosting unless the developer explicitly requests self-hosting.
- Treat external platform assets such as Cloudflare Workers as first-class deployment surfaces, but do not force them into Docker or Compose convergence.

## 6. New Workflow

The skill workflow should be restructured as:

1. Resolve repository root
2. Detect deployable surfaces
3. Build deployment unit matrix
4. Determine recommended baseline action for each unit
5. Output one confirmation message containing the full matrix and per-unit actions
6. Execute per-unit baseline handling after confirmation
7. Run per-unit verification
8. Report per-unit outcomes, carryovers, exclusions, and residual risks

This replaces the current assumption that the workflow only needs to classify the repository once at the top level.

## 7. Deployment Unit Matrix

The skill should always emit a deployment unit matrix before confirmation.

This should be mandatory, not optional.

### 7.1 Required Fields

Each deployment unit row should include:

- `public_surface`
- `code_path`
- `unit_type`
- `runtime`
- `hosting_mode`
- `statefulness`
- `deploy_command`
- `rollback_unit`
- `baseline_action`

### 7.2 Field Meanings

#### `public_surface`

The externally visible domain, hostname, route, or public service entry.

#### `code_path`

The path in the repository that owns the deployment unit.

#### `unit_type`

Suggested examples:

- `app`
- `api`
- `static-site`
- `worker`
- `smtp`

#### `runtime`

Suggested examples:

- `node-http`
- `astro-static`
- `cloudflare-worker`

#### `hosting_mode`

Canonical values:

- `self-hosted`
- `external-static-hosting`
- `external-platform`

#### `statefulness`

Suggested values:

- `stateless`
- `stateful`
- `external-state`

#### `deploy_command`

The known or recommended deployment entry point for the unit.

#### `rollback_unit`

The actual rollback boundary, such as:

- image tag
- git ref
- provider release
- manual restore

#### `baseline_action`

This field determines the execution path the skill should take.

Recommended values:

- `converge-self-hosted`
- `exclude-from-compose`
- `provider-managed`
- `document-only`

## 8. Confirmation Gate Redesign

The skill should still keep a single confirmation point.

However, that confirmation must stop being repository-global and become matrix-aware.

### 8.1 Old Confirmation Model

The old model assumes one of:

- confirm the plan
- choose conservative or forced

This is not enough for mixed-hosting monorepos.

### 8.2 New Confirmation Model

The confirmation message should contain:

- repository root
- deployment unit matrix
- per-unit recommended baseline action
- per-unit high-risk areas
- unresolved low-confidence fields that require user input

The user still confirms once, but can confirm multiple unit decisions in that single message.

### 8.3 Examples Of Per-Unit Confirmation Decisions

- `core: conservative self-hosted convergence`
- `www: external static hosting, do not Dockerize`
- `worker: provider-managed, document deploy command only`

The skill must not fall back to per-file questioning after this single confirmation.

## 9. Mixed Baseline Execution Model

After confirmation, the skill should not treat the repository as one deploy surface.

It should execute per deployment unit according to `baseline_action`.

### 9.1 `converge-self-hosted`

Use this for units that belong inside the traditional deploy baseline.

Expected work may include:

- Compose convergence
- `Makefile` command mapping
- deploy scripts
- env examples
- deployment docs

Typical examples:

- self-hosted API
- self-hosted app server
- self-hosted SMTP or worker process

### 9.2 `exclude-from-compose`

Use this when a unit is deployable but should not be forced into Docker or Compose.

Expected work may include:

- build command documentation
- output directory documentation
- env contract documentation
- host assumptions
- DNS, CDN, or cache notes

Typical examples:

- Astro marketing site
- Vite static site
- Next.js static export

### 9.3 `provider-managed`

Use this for deployable units that belong to an external platform.

Expected work may include:

- provider name
- manifest or config file identification
- deploy command
- required secrets
- ownership boundary
- rollback unit description

Typical examples:

- Cloudflare Worker
- Vercel function surface
- Pages-style external platform target

These units should be treated as first-class deployment surfaces, not as "missing self-hosted baseline pieces".

### 9.4 `document-only`

Use this when the skill should acknowledge a deployment unit but not actively converge its deployment assets.

This may apply when:

- the deployment is fully external and already stable
- the repository only needs ownership and boundary documentation for that unit
- the unit is out of scope for current convergence but still relevant to the deployment picture

## 10. Static Site Rule Set

The skill should add a dedicated rule path for externally hosted static sites.

For static sites, the default should be:

- do not Dockerize unless explicitly requested
- do not create Compose services by default
- do generate or verify:
  - build command
  - output directory
  - env contract
  - host requirements
  - DNS or CDN assumptions
  - cache policy notes when relevant

This avoids a common false negative where "not in Compose" is incorrectly treated as "not covered by baseline".

## 11. External Platform Rule Set

The skill should add a dedicated rule path for external platform assets.

For these units, always identify:

- platform name
- manifest file
- deploy command
- required secrets
- ownership boundary
- whether they are included in self-hosted rollback

The skill should document these units clearly, but should not force them into self-hosted convergence.

## 12. Verification Model Redesign

Verification should be selected per deployment unit type, not only per repository.

### 12.1 Self-Hosted Service Verification

Minimum expected checks:

- `bash -n`
- `docker compose config`
- `make help`
- project build, test, or typecheck if present
- healthcheck presence
- env file existence or documentation
- rollback boundary notes

### 12.2 Static Site Verification

Minimum expected checks:

- build command
- output directory existence
- route or base path assumptions
- env contract
- hosting notes
- DNS, CDN, or cache notes where relevant

### 12.3 External Platform Verification

Minimum expected checks:

- manifest or config existence
- deploy command presence
- required secrets documented
- optional lint or dry-run command if available
- ownership boundary documented
- rollback inclusion or exclusion documented

### 12.4 Reporting Rule

The skill must not treat "not in Compose" as evidence that a deployable surface has no baseline.

It must instead report which verification path was applied to each deployment unit.

## 13. Final Output Contract

The final report should no longer be repository-global only.

It must include per-unit reporting:

- kept
- converged
- excluded from Compose
- provider-managed
- unresolved risks
- verification status

This makes the outcome understandable for mixed-hosting repositories.

## 14. Phase Strategy

This design should be implemented in two phases.

### Phase 1

Refactor the skill’s analysis model, planning output, confirmation structure, and verification model so it understands deployment unit matrices.

This phase updates:

- thinking model
- output model
- confirmation model
- verification selection model

### Phase 2

Update execution rules and references so file generation, convergence, and reporting operate per deployment unit rather than per repository only.

This phase updates:

- actual convergence behavior
- transformation rules
- document generation logic
- final reporting logic

## 15. Files Likely To Change

When implementing this design, the most relevant files are:

- `skills/deploy-baseline-kit/SKILL.md`
- `skills/deploy-baseline-kit/references/project-analysis.md`
- `skills/deploy-baseline-kit/references/mode-detection.md`
- `skills/deploy-baseline-kit/references/transformation-rules.md`
- `skills/deploy-baseline-kit/references/verification.md`
- `docs/deploy-baseline-kit.md`

## 16. Non-Goals

This design does not attempt to:

- make every external provider fully supported in one pass
- force all deployment units into Docker
- force all units to share one deploy directory
- force branch strategy to mirror hosting strategy

## 17. Expected Result

When this design is implemented, `deploy-baseline-kit` should stop behaving like a single-project deploy normalizer and start behaving like a multi-surface deployment baseline orchestrator.

That is the correct mental model for:

- monorepos
- mixed self-hosted and externally hosted products
- repositories where public domains, deploy commands, and rollback boundaries are intentionally different across units
