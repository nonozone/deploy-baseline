---
name: deploy-baseline-kit
description: Use when a developer wants Codex to inspect any project directory, identify the repository root, detect deployable and command surfaces, build a deployment unit matrix, and then generate or converge baseline deployment assets per unit with a single confirmation before file edits.
---

# Deploy Baseline Kit

Inspect a target directory, identify deployable surfaces, then plan baseline generation or convergence **per deployment unit**. Present one modification plan before editing files.

Keep the user interaction simple: analyze first, ask once, then execute.

Product stance:

- prefer converging the target project toward the deploy baseline
- do not preserve local variance by default
- record necessary deviations as explicit `exceptions`

## Workflow

1. Resolve the repository root before planning any edits.
2. Detect deployable surfaces and command surfaces (code paths, public entry points, deploy commands, project-level commands, unit-level scripts, existing deployment assets).
3. Build a deployment unit matrix (single-project repos are a one-row matrix).
4. Build a command surface matrix (single-project repos may still have both project-level and unit-level rows).
5. Determine a recommended baseline action per unit.
6. Emit one confirmation message containing the full matrices and any unresolved low-confidence fields.
7. After confirmation, execute per-unit handling without per-file follow-up questions.
8. Generate or update deployment docs so the chosen baseline actions are visible per unit.
9. Run per-unit verification (only what applies to that unit's hosting mode).
10. Report outcomes per unit: what changed, what was excluded, and residual risks/carryovers.

## Confirmation Gate

Use only one confirmation point.

- The confirmation message must be **matrix-aware**: multiple deployment units, each with its own recommended handling.
- For `self-hosted` units, include `dev_mode` (`full-docker` vs `hybrid`) and what `make dev` will start (and what is excluded).
- Conservative vs forced remains available, but **only as a per-unit choice** when a unit is eligible for convergence (typically `converge-self-hosted`).
- If any per-unit fields cannot be determined reliably, ask for that information inside the same confirmation message (do not open a second confirmation loop).

Do not ask again after the user confirms.

### Per-Unit Confirmation Examples

Examples of decisions the user can confirm (or override) inside the single confirmation:

- `core: self-hosted, dev_mode=hybrid, converge-self-hosted (conservative) (make dev: core + shared infra)`
- `www: external-static-hosting, exclude-from-compose (do not Dockerize by default, but still treat as baseline-in-scope)`
- `worker: external-platform, provider-managed (manifest/config + deploy/local-dev command + secrets/ownership + rollback boundary documented)`

## Execution Rules

- Treat the baseline structure as the target outcome.
- Prefer replacing project-local drift with the baseline shape unless a necessary exception applies.
- Apply baseline actions per unit; **same repository does not imply same deploy target**.
- Do not Dockerize `external-static-hosting` units by default.
- Treat `external-platform` units as first-class surfaces, but do not force them into Docker/Compose convergence.
- For `provider-managed` units, preserve or introduce provider config/manifests and document deploy, local dev (if applicable), secrets ownership, and rollback boundaries.
- Prefer migrating or preserving project-specific logic over deleting it silently.
- If a project detail cannot be normalized safely, surface it explicitly as an `exception` instead of quietly retaining drift.
- Use the bundled template as the default skeleton for new files.
- Adapt the template instead of copying it blindly when the project already has meaningful deployment logic.
- Generate deployment docs from the baseline SOP plus project-specific facts discovered during scanning.
- For multi-unit repositories, document a deployment-unit matrix and clearly mark which units are self-hosted, externally hosted, provider-managed, included in `make deploy`, or excluded from rollback.
- Prefer one operator-facing `deploy/README.md` with per-unit sections; split into additional unit docs only when one shared document would become ambiguous or too large.
- Keep the root command contract project-level and stable.
- Preserve unit-native command runners and scripts when they already provide clean unit-level entry points.
- Do not assume every unit exposes `dev`; report missing unit-level scripts instead of inventing them.
- Do not stop at file generation. Always verify the resulting deployment surface.
- Prefer additive or merge-style edits for existing system-facing config such as reverse proxies or service units.
- Full-file replacement of system-facing config is only allowed when the user explicitly chooses **forced convergence for that unit**.
- Keep env examples grouped by concern and clearly separate `deploy/env/app.dev.env` from `deploy/env/app.prod.env`.
- When an existing `deploy/env/app.prod.env` is present, prefer non-destructive env sync that inserts missing keys by example-group order instead of overwriting the file.
- If a legacy root `.env` exists and `deploy/env/app.dev.env` does not, copy it once during setup and state clearly that this is a migration bridge.
- When introducing a new env layout or new deploy env files into an existing project, first inspect the current env files and migrate valid values forward; never replace an existing `.env`, `.env.local`, or deploy env file wholesale just because the baseline uses a different layout.
- Always state the rollback unit per deployment unit: git ref, image tag, provider release, or manual restore boundary.
- If database migrations exist, document rollback boundaries explicitly instead of implying full reversibility.

## References

- Read [root-detection.md](references/root-detection.md) when the current working directory may not be the actual project root.
- Read [project-analysis.md](references/project-analysis.md) to classify deployment unit maturity and inventory existing deployment assets.
- Read [command-surfaces.md](references/command-surfaces.md) to distinguish project-level commands from unit-level commands and build a command surface matrix without assuming every unit exposes the same scripts.
- Read [mode-detection.md](references/mode-detection.md) to choose `hosting_mode` per unit and, for `self-hosted` units, decide `dev_mode` (`full-docker` vs `hybrid`) without assuming one repo-wide mode.
- Read [database-variants.md](references/database-variants.md) to detect PostgreSQL, MySQL, MariaDB, MongoDB, external databases, or unknown database setups.
- Read [transformation-rules.md](references/transformation-rules.md) before editing files.
- Read [document-generation.md](references/document-generation.md) when generating or rewriting `deploy/README.md` or baseline notes.
- Read [verification.md](references/verification.md) after edits to verify per unit type: `self-hosted` (Compose/scripts/command surface/build health), `external-static-hosting` (build/output/routing/env contract/hosting notes), and `external-platform` (manifest/deploy/secrets/rollback boundaries).

## Required Planning Output

Before confirmation, always include:

- repository root
- deployment unit matrix (single-project repos are a one-row matrix)
- command surface matrix
- per-unit hosting mode
- per-unit `dev_mode` (only for `self-hosted` units)
- per-unit rollback unit
- per-unit baseline action
- current assets by unit
- unresolved low-confidence fields (per-unit or repo-level)
- documentation output plan
- verification plan by unit

The command surface matrix should be operator-readable (table or bullet rows) and include, at minimum:

- `scope`
- `unit_name`
- `code_path`
- `runner`
- `available_commands`
- `missing_expected_commands`
- `recommended_entry`

The deployment unit matrix should be operator-readable (table or bullet rows) and include, at minimum:

- `public_surface`
- `code_path`
- `unit_type`
- `runtime`
- `hosting_mode`
- `statefulness`
- `deploy_command`
- `rollback_unit`
- `baseline_action`

## Bundled Resources

- `scripts/detect-root.sh` performs a deterministic upward scan for likely project roots.
- `assets/template/` contains the packaged baseline skeleton derived from `src/template/`.
- `product.md` summarizes the product stance for packaged installations.
