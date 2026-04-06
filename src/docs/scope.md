# Supported Scope

Best-supported path:

- existing PostgreSQL-backed projects
- repositories that need deploy baseline convergence
- repositories that benefit from normalized `Makefile`, env layout, deploy scripts, and deploy docs

Secondary supported path:

- near-empty repositories that need a baseline bootstrap

Current product stance:

- standardize toward the deploy baseline
- do not preserve local variance by default
- use explicit `exceptions` for necessary deviations
