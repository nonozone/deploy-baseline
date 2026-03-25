---
name: deploy-baseline-kit
description: Use when a developer wants Codex to inspect any project directory, identify the real project root, detect deployment and database setup, and then generate or normalize Docker Compose, Makefile, deploy scripts, env examples, and deployment docs against this deploy baseline with a single confirmation before file edits.
---

# Deploy Baseline Kit

Inspect a target directory, decide whether it needs baseline generation or baseline convergence, then present one modification plan before editing files.

Keep the user interaction simple: analyze first, ask once, then execute.

## Workflow

1. Resolve the project root before planning any edits.
2. Scan the project and classify it as:
   - empty or near-empty
   - lightweight existing project
   - heavy existing deployment project
3. Detect deployment mode, database type, and whether the database is containerized or external.
4. Produce one plan that includes:
   - root path
   - current assets
   - gaps against the baseline
   - recommended path
   - risk summary
5. Ask for one confirmation only.
6. After confirmation, execute the plan without per-file follow-up questions.
7. Run post-edit verification for deployment assets and command surface.
8. Report what changed, what still deviates, and any project-specific carryovers.

## Confirmation Gate

Use only one confirmation point.

- For empty or lightweight projects, present the proposed baseline generation or convergence plan and ask for confirmation.
- For heavy existing deployment setups, include the same plan plus a required choice between conservative adaptation and forced convergence.
- If deployment mode or database type cannot be determined reliably, ask for that information inside the same confirmation message.

Do not ask again after the user confirms.

## Execution Rules

- Treat the baseline structure as the target outcome.
- Prefer migrating or preserving project-specific logic over deleting it silently.
- Use the bundled template as the default skeleton for new files.
- Adapt the template instead of copying it blindly when the project already has meaningful deployment logic.
- Generate deployment docs from the baseline SOP plus project-specific facts discovered during scanning.
- Do not stop at file generation. Always verify the resulting deployment surface.
- Prefer additive or merge-style edits for existing system-facing config such as reverse proxies or service units.
- Keep env examples grouped by concern and clearly separate local or dev files from production files.
- Always state the rollback unit: git ref, image tag, or manual restore.
- If database migrations exist, document rollback boundaries explicitly instead of implying full reversibility.

## References

- Read [root-detection.md](references/root-detection.md) when the current working directory may not be the actual project root.
- Read [project-analysis.md](references/project-analysis.md) to classify project maturity and inventory existing deployment assets.
- Read [mode-detection.md](references/mode-detection.md) to decide between full Docker and hybrid development.
- Read [database-variants.md](references/database-variants.md) to detect PostgreSQL, MySQL, MariaDB, MongoDB, external databases, or unknown database setups.
- Read [transformation-rules.md](references/transformation-rules.md) before editing files.
- Read [document-generation.md](references/document-generation.md) when generating or rewriting `deploy/README.md` or baseline notes.
- Read [verification.md](references/verification.md) after edits to verify Compose, scripts, command surface, and project build or test health.

## Required Planning Output

Before confirmation, always include:

- root path
- project classification
- deployment mode
- database type and persistence mode
- current assets
- missing baseline pieces
- recommended path
- highest-risk edits
- verification plan

## Bundled Resources

- `scripts/detect-root.sh` performs a deterministic upward scan for likely project roots.
- `assets/template/` contains the baseline skeleton to adapt for generated files.
