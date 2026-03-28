# Fixture Metadata

- name: mysql-compare
- scenario: mysql comparison project
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: docker
- expected_database: mysql
- expected_project_commands: none
- expected_unit_commands: none
- expected_command_recommendation: confirm database handling first, then converge project-level commands conservatively
- support_level: experimental
- expected_recommendation: conservative convergence with explicit database confirmation
- verification_level: static
- notes: validates that non-postgresql projects are detected and described conservatively
