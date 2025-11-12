.PHONY: help init-dev init-prod plan-dev plan-prod apply-dev apply-prod destroy-dev destroy-prod fmt validate clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init-dev: ## Initialize Terraform for dev environment
	cd envs/dev && terraform init

init-prod: ## Initialize Terraform for prod environment
	cd envs/prod && terraform init

plan-dev: ## Run Terraform plan for dev environment
	cd envs/dev && terraform plan -var-file=dev.tfvars

plan-prod: ## Run Terraform plan for prod environment
	cd envs/prod && terraform plan -var-file=prod.tfvars

apply-dev: ## Apply Terraform changes for dev environment
	cd envs/dev && terraform apply -var-file=dev.tfvars

apply-prod: ## Apply Terraform changes for prod environment
	cd envs/prod && terraform apply -var-file=prod.tfvars

destroy-dev: ## Destroy Terraform resources in dev environment
	cd envs/dev && terraform destroy -var-file=dev.tfvars

destroy-prod: ## Destroy Terraform resources in prod environment
	cd envs/prod && terraform destroy -var-file=prod.tfvars

fmt: ## Format all Terraform files
	terraform fmt -recursive

validate-dev: ## Validate dev Terraform configuration
	cd envs/dev && terraform validate

validate-prod: ## Validate prod Terraform configuration
	cd envs/prod && terraform validate

output-dev: ## Show dev Terraform outputs
	cd envs/dev && terraform output

output-prod: ## Show prod Terraform outputs
	cd envs/prod && terraform output

clean: ## Clean Terraform cache and plans
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "tfplan" -delete
	find . -type f -name ".terraform.lock.hcl" -delete

docs: ## Generate documentation using terraform-docs
	terraform-docs markdown table --output-file README.md --output-mode inject modules/ecr/

