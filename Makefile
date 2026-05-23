# aws-cost-analyzer Makefile
# Run `make help` to see available targets.
# All terraform commands run from the terraform/ directory.

TERRAFORM_DIR := terraform
TF := cd $(TERRAFORM_DIR) && terraform

.PHONY: help init plan apply destroy cost cost-cli fmt validate

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform (download providers)
	$(TF) init

plan: ## Preview what Terraform will create/change
	$(TF) plan

apply: ## Deploy cost alerts to AWS
	$(TF) apply

destroy: ## Remove all resources created by this repo
	@echo "This will delete your budget alerts and SNS topic."
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ] || exit 1
	$(TF) destroy

fmt: ## Auto-format all Terraform files
	$(TF) fmt -recursive

validate: ## Validate Terraform configuration
	$(TF) validate

cost: ## Python breakdown: MTD spend by service (requires: pip install boto3)
	python scripts/cost-breakdown.py

cost-cli: ## Shell breakdown: MTD total, top 5 services, forecast (requires: aws CLI + jq)
	bash scripts/quick-costs.sh
