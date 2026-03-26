# Fixtures

This directory holds curated fixtures that the repository uses to describe how
`deploy-baseline-kit` should classify, detect modes, and recommend paths. Today
that description resides entirely in static metadata; the `runnable/` subtree is
reserved for the executable verification layer planned for later phases.

## Layout

- Top-level directories under `fixtures/` are static fixtures that only need metadata
  and representative anchors to describe their expected classification.
- `runnable/` is reserved for fully executable fixtures whose verification steps
  will run commands and compose setups without further restructuring the static
  fixtures.

## Metadata contract

Each fixture directory must contain a `fixture.md` whose ordered list records the
following keys so the upcoming metadata validation checks can assert them when
the static verification script is added:

- `name`
- `scenario`
- `expected_root`
- `expected_classification`
- `expected_mode`
- `expected_database`
- `support_level`
- `expected_recommendation`
- `verification_level`
- `notes`

Additional keys are not permitted in phase 1 so the validator can remain simple and
predictable, though the structure keeps room for a `runnable/` subtree once the
executable fixtures land.
