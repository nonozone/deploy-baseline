# Exceptions Policy

If `deploy-baseline-kit` cannot fully normalize a project, it must report an explicit `exceptions` section.

Each exception should state:

- what could not be normalized
- why it could not be normalized
- whether it is temporary or likely permanent
- what manual follow-up is still required

`exceptions` are for necessary deviations only.

They are not a place to quietly preserve:

- historical convenience
- undocumented local habits
- inconsistent naming or file layout
- extra parallel command surfaces

Silent drift is worse than explicit exceptions.
