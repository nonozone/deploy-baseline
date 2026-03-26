# Fixture Metadata

- name: monorepo-subproject
- scenario: monorepo subproject entry
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: hybrid development
- expected_database: postgresql
- support_level: baseline
- expected_recommendation: confirm root and scope before convergence
- verification_level: static
- notes: contains multiple apps and a shared package to exercise root detection boundaries
