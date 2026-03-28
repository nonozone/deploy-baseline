# Fixture Metadata

- name: heavy-existing-deploy
- scenario: heavy existing deployment project
- expected_root: .
- expected_classification: heavy existing deployment project
- expected_mode: docker
- expected_database: postgresql
- expected_project_commands: make help,make deploy
- expected_unit_commands: none
- expected_command_recommendation: preserve project-level make commands and avoid unnecessary root command churn
- support_level: stable
- expected_recommendation: choose conservative or forced convergence
- verification_level: static
- notes: contains make targets, multiple compose files, and existing deploy docs
