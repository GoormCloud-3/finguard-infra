.PHONY: install init fmt validate lint plan apply destroy

# Install pre-commit and register Git hook
install:
	pip install --upgrade pre-commit
	pre-commit install
# Validate Terraform syntax
validate:
	terraform validate
# Run all pre-commit hooks on all files
lint:
	pre-commit run --all-files
# Destroy Terraform-managed infrastructure
destroy:
	terraform destroy
action_test:
	act push --secret-file .secrets