## Initialize the terraform state backend
init:
	@aws s3 ls s3://${TF_BUCKET}/tfstate-backend/terraform.tfstate > /dev/null || \
		scripts/$@.sh
	[ -f .terraform/terraform.tfstate ] || terraform $@

## Destroy the configuration (only works if `force_destroy=true`)
destroy:
	@scripts/$@.sh

## Force destroy the bucket (not recommended!)
force-destroy:
	@scripts/$@.sh

## Clean up the project
clean:
	rm -rf .terraform *.tfstate*

## Pass arguments through to terraform which require remote state
apply console graph plan output providers show: init
	terraform $@

## Pass arguments through to terraform which do not require remote state
get fmt validate version:
	terraform $@
