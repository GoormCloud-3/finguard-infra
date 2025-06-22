.PHONY: install init fmt validate lint plan apply destroy

# Install pre-commit and register Git hook
install:
	pip install --upgrade pre-commit
	pre-commit install

# Initialize Terraform project
init:
	terraform init

# Format all Terraform files
fmt:
	terraform fmt -recursive

# Validate Terraform syntax
validate:
	terraform validate

# Run all pre-commit hooks on all files
lint:
	pre-commit run --all-files

# Plan Terraform changes
plan:
	terraform plan

# Apply Terraform changes
apply:
	terraform apply

# Destroy Terraform-managed infrastructure
destroy:
	terraform destroy
