## Initialize the terraform state backend
init:
	@aws s3 ls s3://${TF_BUCKET}/tfstate-backend/terraform.tfstates > /dev/null || \
		scripts/$@.sh
	@[ -d .terraform ] || init-terraform

## Destroy the configuration (only works if `force_destroy=true`)
destroy:
	@scripts/$@.sh

## Force destroy the bucket (not recommended!)
force-destroy:
	@scripts/$@.sh

## Pass target through to terraform
%:
	terraform $@
