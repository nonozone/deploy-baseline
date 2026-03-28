# Fixture Metadata

- name: monorepo-subproject
- scenario: monorepo subproject entry
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: hybrid development
- expected_database: postgresql
- expected_project_commands: pnpm build,pnpm test
- expected_unit_commands: apps/api=build|test;apps/web=dev|build|test
- expected_command_recommendation: report both project-level and unit-level commands and do not assume every unit has dev
- support_level: baseline
- expected_recommendation: confirm root and scope before convergence
- verification_level: static
- notes: contains multiple apps and a shared package to exercise root detection boundaries
