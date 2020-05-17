up:
	cd infra && terraform init
	cd infra &&	terraform apply --var-file infra/terraform.tfvars --auto-approve

down:
	cd infra && terraform destroy --var-file infra/terraform.tfvars --auto-approve



