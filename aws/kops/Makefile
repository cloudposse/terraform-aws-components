## Initialize terraform remote state
init:
	[ -f .terraform/terraform.tfstate ] || init-terraform

## Clean up the project
clean:
	rm -rf .terraform *.tfstate*

## Pass argument through to terraform
plan apply output destroy show providers graph console: init
	terraform $@

fmt validate version get:
	terraform $@
