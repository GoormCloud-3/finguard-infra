.PHONY: install lint destroy action_test

install:
	pip install --upgrade pre-commit
	pre-commit install
lint:
	pre-commit run --all-files
destroy:
	terraform destroy
action_test:
	act push --secret-file .secrets
