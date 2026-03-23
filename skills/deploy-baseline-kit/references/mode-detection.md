# Mode Detection

Use this reference to decide whether the project should follow full Docker development or hybrid development.

## Full Docker

Prefer this mode when:

- core app services already run in Compose
- local developer flow is container-first
- hot reload and service-to-service dependencies already assume containers

## Hybrid development

Prefer this mode when:

- stateful services such as DB or cache use containers
- the main app runs locally with framework-native commands
- the repo already has local dev scripts that should remain first-class

## If uncertain

Do not guess quietly.

Include the uncertainty in the one confirmation message and ask the developer to confirm the mode there.

## Output language

State:

- chosen mode
- evidence
- what `make dev` will start under that mode
