SHELL := /bin/bash

.PHONY: help verify-fixtures-static verify-baseline build-skill package install-local verify sync-compat sync-rules

help: ## Show repository maintenance commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-24s %s", $$1, $$2; print ""}'

verify-fixtures-static: ## Verify static fixture metadata and layout
	bash scripts/verify-fixtures-static.sh

verify-baseline: verify-fixtures-static ## Run baseline repository verification
	bash scripts/verify-baseline.sh

build-skill: ## Build the self-contained skill package into dist/
	bash scripts/build-skill.sh

sync-compat: ## Refresh compatibility template dirs from src/template
	bash scripts/sync-template-compat.sh

sync-rules: ## Refresh skill references from src/rules/references
	bash scripts/sync-rule-compat.sh

package: ## Create a distributable archive for the skill package
	bash scripts/package-skill.sh

install-local: build-skill ## Install the packaged skill into the local Codex skills dir
	bash scripts/install-local-skill.sh

verify: build-skill verify-baseline ## Run repository and packaged-skill verification
	bash scripts/verify-skill-package.sh
