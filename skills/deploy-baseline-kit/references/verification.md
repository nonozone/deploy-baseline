# Verification

Choose verification **per deployment unit type**.

Do not treat Compose validation as the only verification outcome. Static and provider-managed units are valid deployment surfaces and still require checks, but the checks differ.

## Self-hosted service (minimum checks)

Applies when a unit is `hosting_mode=self-hosted` and typically `baseline_action=converge-self-hosted` (or `exclude-from-compose` but still self-hosted).

### 1. Shell script syntax

- Run `bash -n` for every new or modified `.sh` file.

### 2. Compose expansion (when Compose is in scope for that unit)

- Run `docker compose config`.
- If the production env file is required, use a safe example env or a temporary copied example env.

### 3. Command surface

- Run `make help`.
- Verify newly introduced targets exist and map to real scripts.
- In monorepos, also verify project-level commands and unit-level commands are documented separately.
- Do not claim a unit supports `dev` unless a real unit-level command exists.

### 4. Project health

- If the repo already has build, test, or typecheck commands, run them.
- Do not claim success based only on deploy-file generation.

### 5. Deployment-specific checks

- Verify `healthcheck` exists in production compose.
- Verify env files referenced by compose actually exist or are documented.
- Verify any migration script resolves correct runtime paths in built artifacts.

### 6. Rollback boundary

- Ensure rollback unit is stated per unit (image tag, git ref, host snapshot, etc), or explicitly marked unknown.

## Static site (minimum checks)

Applies when a unit is `hosting_mode=external-static-hosting` (commonly `baseline_action=exclude-from-compose`).

- Run the unit build command (for example `npm run build`) if feasible.
- Verify the documented output directory exists after build (`dist/`, `build/`, `out/`, etc).
- Verify route/base-path assumptions are stated (SPA fallback, asset prefix, subpath deploy).
- Verify env contract is stated (build-time vars vs runtime vars) and any secrets are not committed.
- Verify hosting notes exist (provider, project/site identifier, how deploy is triggered).
- If custom domains/CDN are in play, verify DNS assumptions and CDN/cache policy notes are present (records, caching behavior, invalidation/purge expectations).

## External platform (minimum checks)

Applies when a unit is `hosting_mode=external-platform` (commonly `baseline_action=provider-managed`).

- Verify a manifest/config exists (example: `wrangler.toml`) and is referenced in docs.
- Verify deploy command exists (script, Make target, or provider CLI command) and is documented.
- Verify required secrets are documented and ownership boundaries are stated (who can rotate, where they live).
- If the provider has a lint/dry-run command, run it when feasible.
- Verify rollback is documented, or explicitly documented as unavailable/out of scope.
- Verify rollback inclusion/exclusion is explicitly documented relative to self-hosted rollback (`included` / `excluded`) and the operational meaning is stated.

## Reporting

Report results per unit. For monorepos, also report project-level versus unit-level command verification separately. When verification cannot be completed, say exactly which check was skipped and why.
