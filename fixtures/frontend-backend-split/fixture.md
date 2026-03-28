# Fixture Metadata

- name: frontend-backend-split
- scenario: frontend backend split project
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: hybrid development
- expected_database: postgresql
- expected_project_commands: none
- expected_unit_commands: backend=build|test;frontend=dev|build|test
- expected_command_recommendation: keep split unit-level commands and add project-level defaults only if needed
- support_level: stable
- expected_recommendation: conservative convergence
- verification_level: static
- notes: frontend and backend are separate directories with backend-first deploy baseline focus
