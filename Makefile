SHELL := /bin/bash

.PHONY: help verify-fixtures-static verify-baseline

help: ## Show repository maintenance commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-24s %s", $$1, $$2; print ""}'

verify-fixtures-static: ## Verify static fixture metadata and layout
	bash scripts/verify-fixtures-static.sh

verify-baseline: verify-fixtures-static ## Run baseline repository verification
