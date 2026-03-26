# Fixture Metadata

- name: mysql-compare
- scenario: mysql comparison project
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: docker
- expected_database: mysql
- support_level: experimental
- expected_recommendation: conservative convergence with explicit database confirmation
- verification_level: static
- notes: validates that non-postgresql projects are detected and described conservatively
