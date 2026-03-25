# Verification

Run these checks after editing deployment assets.

## Required checks

### 1. Shell script syntax

- Run `bash -n` for every new or modified `.sh` file.

### 2. Compose expansion

- Run `docker compose config`.
- If the production env file is required, use a safe example env or a temporary copied example env.

### 3. Command surface

- Run `make help`.
- Verify newly introduced targets exist and map to real scripts.

### 4. Project health

- If the repo already has build, test, or typecheck commands, run them.
- Do not claim success based only on deploy-file generation.

### 5. Deployment-specific checks

- Verify `healthcheck` exists in production compose.
- Verify env files referenced by compose actually exist or are documented.
- Verify any migration script resolves correct runtime paths in built artifacts.

## Reporting

When verification cannot be completed, say exactly which check was skipped and why.
