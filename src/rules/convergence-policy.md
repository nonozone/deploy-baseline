# Convergence Policy

`deploy-baseline-kit` is a baseline convergence product.

Default stance:

- normalize the target project toward the deploy baseline
- reduce project-local drift
- prefer standard command surfaces, env layout, deploy structure, and deploy docs

This product should not treat every existing project convention as equally valid.

When the baseline and the project differ, the default choice is:

- change the project toward the baseline

Not:

- preserve local variance by default

The only acceptable reasons to keep a divergence are:

- direct migration is technically infeasible
- migration risk is too high for safe automation
- the project has a necessary business or platform constraint
