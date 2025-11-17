.PHONY: help init plan apply destroy fmt validate clean docs drift

ENV ?= dev
LAYER ?= data

help: ## Show this help message
	@echo 'Usage: make [target] [ENV=env] [LAYER=layer]'
	@echo ''
	@echo 'Environments: dev, stage, prod'
	@echo 'Layers: platform, data, app'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform for specified environment and layer
	@./scripts/tf-wrapper.sh $(ENV) $(LAYER) init

plan: ## Run Terraform plan for specified environment and layer
	@./scripts/tf-wrapper.sh $(ENV) $(LAYER) plan

apply: ## Apply Terraform changes for specified environment and layer
	@./scripts/tf-wrapper.sh $(ENV) $(LAYER) apply

destroy: ## Destroy Terraform resources for specified environment and layer
	@./scripts/tf-wrapper.sh $(ENV) $(LAYER) destroy

validate: ## Validate Terraform configuration for specified environment and layer
	@./scripts/tf-wrapper.sh $(ENV) $(LAYER) validate

output: ## Show Terraform outputs for specified environment and layer
	@./scripts/tf-wrapper.sh $(ENV) $(LAYER) output

fmt: ## Format all Terraform files
	terraform fmt -recursive

validate-all: ## Validate all environments and layers
	@for env in dev stage prod; do \
		for layer in platform data app; do \
			echo "Validating $$env/$$layer..."; \
			./scripts/tf-wrapper.sh $$env $$layer validate || exit 1; \
		done; \
	done

plan-all: ## Plan all environments and layers
	@for env in dev stage prod; do \
		for layer in platform data app; do \
			echo "Planning $$env/$$layer..."; \
			./scripts/tf-wrapper.sh $$env $$layer plan; \
		done; \
	done

drift: ## Check for infrastructure drift
	@./scripts/drift-detection.sh $(ENV) $(LAYER)

clean: ## Clean Terraform cache and plans
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "tfplan" -delete
	find . -type f -name ".terraform.lock.hcl" -delete
	find . -type f -name "plan.txt" -delete

docs: ## Generate documentation using terraform-docs
	@for module in modules/*/; do \
		if [ -f "$$module/README.md" ]; then \
			echo "Generating docs for $$module"; \
			terraform-docs markdown table --output-file README.md --output-mode inject "$$module" || true; \
		fi; \
	done

# Convenience targets for common operations
init-dev: ## Initialize dev environment
	@$(MAKE) init ENV=dev LAYER=data

plan-dev: ## Plan dev environment
	@$(MAKE) plan ENV=dev LAYER=data

apply-dev: ## Apply dev environment
	@$(MAKE) apply ENV=dev LAYER=data

plan-prod: ## Plan prod environment (requires layer)
	@echo "Usage: make plan-prod LAYER=platform|data|app"

apply-prod: ## Apply prod environment (requires layer)
	@echo "Usage: make apply-prod LAYER=platform|data|app"
