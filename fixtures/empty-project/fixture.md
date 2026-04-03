# Fixture Metadata

- name: empty-project
- scenario: empty project directory
- expected_root: .
- expected_classification: empty project
- expected_mode: unknown
- expected_database: unknown
- expected_project_commands: none
- expected_unit_commands: none
- expected_command_recommendation: establish project-level commands first
- support_level: stable
- expected_recommendation: generate baseline skeleton
- verification_level: static
- notes: contains no deployment assets and should be treated as a near-empty project

<!-- layout_files: intentionally empty -->
<!-- This fixture represents a near-empty directory. No layout files are required by design. -->
<!-- verify-fixtures-static.sh has no layout checks for empty-project, which is correct. -->
