# Document Generation

Use this reference when creating or rewriting deployment documentation.

## Required docs

Generate or update:

- `deploy/README.md`
- project-specific baseline notes when the repo keeps them

## `deploy/README.md` minimum sections

Include:

1. deployment scope
2. prerequisites
3. local run mode
4. service release split
5. standard directory layout
6. env files and secret sourcing
7. deploy checks
8. deploy flow
9. startup contract and completion criteria
10. logs and health checks
11. rollback flow
12. common troubleshooting
13. project-specific notes

## Source of truth

Use:

- the deploy baseline standard
- the deployment SOP
- facts discovered in the target project

Do not leave the document as generic template prose when the project already exposes concrete ports, services, or commands.
