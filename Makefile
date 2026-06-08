.PHONY: validate validate-schemas validate-openapi validate-yaml lint help

help:
	@echo "skillspec — AI Agent Skill Specification"
	@echo ""
	@echo "Targets:"
	@echo "  validate          Run all validation checks"
	@echo "  validate-schemas  Validate JSON Schema files are well-formed"
	@echo "  validate-openapi  Validate OpenAPI document (requires vacuum or redocly)"
	@echo "  validate-yaml     Validate YAML example files are well-formed"
	@echo "  lint              Alias for validate"

validate: validate-schemas validate-openapi validate-yaml
	@echo "All validation passed."

validate-schemas:
	@echo "--- Validating JSON schemas ---"
	@if command -v python3 >/dev/null 2>&1; then \
		python3 -c "import json, sys; [json.load(open(f)) for f in sys.argv[1:]]" \
			schemas/skill.schema.json \
			schemas/agent-skills.schema.json \
			schemas/agent-skills-lock.schema.json \
		&& echo "JSON schemas: OK"; \
	else \
		echo "python3 not found; skipping JSON parse check"; \
	fi

validate-openapi:
	@echo "--- Validating OpenAPI document ---"
	@if command -v vacuum >/dev/null 2>&1; then \
		vacuum lint openapi/registry-api-v1.openapi.yaml && echo "OpenAPI (vacuum): OK"; \
	elif command -v redocly >/dev/null 2>&1; then \
		redocly lint openapi/registry-api-v1.openapi.yaml && echo "OpenAPI (redocly): OK"; \
	elif command -v npx >/dev/null 2>&1; then \
		npx @redocly/cli lint openapi/registry-api-v1.openapi.yaml && echo "OpenAPI (npx redocly): OK"; \
	else \
		echo "No OpenAPI linter found. Install vacuum (https://quobix.com/vacuum/) or @redocly/cli to enable this check."; \
	fi

validate-yaml:
	@echo "--- Validating YAML example files ---"
	@if command -v python3 >/dev/null 2>&1; then \
		python3 -c "import yaml, sys; [yaml.safe_load(open(f)) for f in sys.argv[1:]]" \
			examples/skill.yaml \
			examples/agent-skills.yaml \
			examples/agent-skills.lock.yaml \
			examples/package/skill.yaml \
			examples/package/CHANGELOG.md \
		2>&1 && echo "YAML examples: OK" || echo "YAML validation failed (PyYAML required: pip install pyyaml)"; \
	else \
		echo "python3 not found; skipping YAML parse check"; \
	fi

lint: validate
