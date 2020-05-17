up:
	cd infra && terraform init
	cd infra &&	terraform apply --var-file variables.tfvars --auto-approve

down:
	cd infra && terraform destroy --var-file variables.tfvars --auto-approve



