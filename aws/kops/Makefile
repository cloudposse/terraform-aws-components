## Initialize terraform remote state
init:
	init-terraform

## Show terraform plan for this project
plan: init
	terraform plan

## Apply terraform plan for this project
apply: init
	terraform apply $(TERRAFORM_ARGS)

## Destroy terraform project
destroy: init
	terraform destroy $(TERRAFORM_ARGS)
