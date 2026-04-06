# `deploy-baseline-kit` Productization Design

## 1. Goal

Reposition this repository from a mixed "template repo + skill + design archive" into a single, installable `deploy-baseline-kit` skill product.

The product's primary job is:

- inspect an existing project
- explain how it differs from the deploy baseline
- converge the project toward the baseline

Secondary job:

- bootstrap a near-empty project with the baseline

This is intentionally not a compatibility-first assistant. It is a baseline convergence product.

## 2. Product Positioning

`deploy-baseline-kit` should be treated as:

- a standalone skill product
- self-contained for offline installation
- optimized for standardizing existing projects

It should not be treated as:

- a template repository that happens to include a skill
- a patchwork migration helper that preserves every local convention
- a multi-source system with equal authority split across repo areas

## 3. Core Principles

### 3.1 Skill-First

The primary user-facing entrypoint is the skill itself.

The repository exists to build, verify, and ship that skill.

### 3.2 Single Source Of Truth

There must be exactly one editable source for the baseline template and product rules.

No long-lived, hand-maintained duplicate template trees are allowed.

### 3.3 Baseline Over Local Drift

For existing projects, the default action is to move the project toward the deploy baseline.

The skill should prefer:

- replacing local variance with baseline structure
- normalizing command surfaces
- normalizing env layout
- normalizing deploy docs

It should not default to preserving project-local conventions unless necessary.

### 3.4 Explicit Exceptions

If some part of a project cannot be converged safely, that must be recorded as an explicit exception.

Exceptions are allowed only when:

- direct migration is technically infeasible
- migration risk is too high for an automatic change
- the project has a necessary business or platform constraint

Silent divergence is not allowed.

### 3.5 Product-Like Interaction

The skill should feel like a standardization tool, not an improvisational assistant.

That means:

- short recognition output
- short convergence plan
- one main confirmation gate
- bounded execution
- explicit exceptions and residual work

## 4. User Workflow

The standard flow should be:

1. Inspect project structure and current deployment shape
2. Detect baseline gaps
3. Output a concise convergence proposal
4. Ask for one main confirmation
5. Apply the convergence changes
6. Run verification
7. Report changes, exceptions, and remaining manual work

The default interaction should be closer to a short assessment report than a long conversational back-and-forth.

## 5. Repository Problems To Fix

The current repository shape has product drift in several places:

- `template/` and `skills/deploy-baseline-kit/assets/template/` behave like parallel template sources
- `docs/` mixes product docs with design-process artifacts
- the repository homepage still reads partly like a baseline repo and partly like a skill repo
- validation currently verifies consistency, but the shape being verified is still historically layered

This creates a "works, but does not feel standardized" outcome.

## 6. Target Repository Shape

The repository should converge toward the following conceptual structure:

```text
deploy-baseline-kit/
  README.md
  Makefile
  skill/
    SKILL.md
    product.md
  src/
    template/
    docs/
    rules/
  fixtures/
  scripts/
    build-skill.sh
    verify.sh
    package.sh
    install-local.sh
  dist/
    deploy-baseline-kit/
```

### 6.1 Meaning Of Each Layer

#### `skill/`

The product entrypoint.

Contains:

- the installable skill contract
- product-facing usage instructions
- references needed by the skill runtime

#### `src/template/`

The only editable baseline template source.

This replaces the long-term need to hand-maintain multiple template copies.

#### `src/docs/`

User-facing product documentation fragments or source docs that are consumed during packaging.

#### `src/rules/`

Canonical product rules, convergence policy, and exception handling guidance used by the skill.

#### `dist/`

Build output only.

This is what should be installed or packaged for distribution.

#### `fixtures/`

Regression and validation samples only.

They are not part of the product's public identity.

## 7. Source And Build Model

The product must distinguish between:

- editable source
- generated distribution assets

Recommended rule:

- `src/template/` is the only editable template tree
- any template embedded in the installable skill package is generated from `src/template/`

If a packaged `assets/template/` directory exists, it must be treated as generated output, not hand-edited source.

## 8. Documentation Model

Documentation should be split into two classes.

### 8.1 Product Docs

These are user-facing and should stay near the front door:

- what the skill is
- who it is for
- how to install it
- how to run it
- what it standardizes
- what it does not support

### 8.2 Internal Design Docs

These are maintainers' materials and should not dominate product navigation:

- specs
- plans
- exploratory design notes
- roadmap drafts

These should move under an internal-only location such as:

- `internal/`
- `design/`

The exact name is less important than keeping them out of the main product path.

## 9. Behavior Contract For Existing Projects

Because the primary scenario is retrofitting real projects, the skill should be opinionated.

Default expectation:

- converge project structure toward the baseline
- reduce variance
- remove accidental local patterns when safe

This should apply to:

- `Makefile` command surface
- env file layout
- deploy directory structure
- deploy documentation shape
- script naming and role boundaries

The skill should not behave as if every existing project convention deserves equal preservation.

## 10. Exception Model

When the skill cannot fully converge a project, the output should include an `exceptions` section with:

- what could not be normalized
- why it could not be normalized
- whether it is a temporary hold or a permanent constraint
- what manual follow-up is still required

This makes deviation visible and keeps the product standard strict.

## 11. Phase 1 Refactor Scope

Phase 1 should focus on product shape, not feature expansion.

Execution note:

- `skills/deploy-baseline-kit/` remains the live skill entry during the transition
- `src/template/` is the new canonical template source starting point
- legacy `template/` and `skills/deploy-baseline-kit/assets/template/` may remain temporarily, but only as compatibility layers on the way to generated output

### 11.1 Required Outcomes

- make the repository read as a skill product first
- define one editable source tree
- remove hand-maintained duplicate template trees
- separate product docs from internal design docs
- add clear build/package/install/verify commands
- define the convergence-first behavior contract

### 11.2 Not In Scope

- adding more database product lines
- broadening provider support
- growing the template feature surface
- redesigning every fixture in depth

Phase 1 is about coherence, not capability growth.

## 12. Product Commands

The repository should expose a simple product-oriented command surface such as:

- `make build-skill`
- `make verify`
- `make package`
- `make install-local`

Expected semantics:

- `build-skill`: generate the distributable self-contained skill package
- `verify`: verify source integrity, package sync, and fixture regressions
- `package`: prepare a versioned distributable artifact
- `install-local`: install the packaged skill into the local Codex skill directory for testing

## 13. Completion Criteria

Phase 1 is complete when:

- the repository homepage clearly presents a skill product
- maintainers edit only one baseline source tree
- distribution assets are generated, not co-authored by hand
- installable skill output is self-contained
- existing-project convergence is clearly baseline-first
- deviations are explicitly surfaced as exceptions

## 14. Summary

The intended end state is simple:

- one product
- one source of truth
- one standard interaction model
- one clear bias toward baseline convergence

Anything that preserves the current multi-identity shape should be treated as an intermediate state, not the product goal.
