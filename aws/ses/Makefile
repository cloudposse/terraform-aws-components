-include .terraform/modules/**/Makefile.ses
## Initialize terraform remote state
init:
	[ -d .terraform ] || init-terraform

## Clean up the project
clean:
	rm -rf .terraform *.tfstate*

## Pass argument through to terraform
%: init
	terraform $@
