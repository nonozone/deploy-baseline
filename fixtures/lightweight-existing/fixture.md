# Fixture Metadata

- name: lightweight-existing
- scenario: lightweight existing project
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: hybrid development
- expected_database: postgresql
- expected_project_commands: none
- expected_unit_commands: app/main.sh
- expected_command_recommendation: converge on project-level make commands while preserving unit-specific entry points
- support_level: stable
- expected_recommendation: conservative convergence
- verification_level: static
- notes: contains app code, partial env, and incomplete deploy assets
