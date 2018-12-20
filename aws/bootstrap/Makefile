AWS_DEFAULT_REGION := us-east-1
IAM_ROLE ?= bootstrap
IAM_POLICY_ARN ?= arn:aws:iam::aws:policy/AdministratorAccess 

export AWS_ROOT_ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query 'Account')

export ASSUME_ROLE_POLICY=$(shell envsubst < assume-role.json > /tmp/assume-role.json; echo file:///tmp/assume-role.json)

## Provision a temporary IAM role for bootstrapping
create/iam-role:
	@aws iam create-role --role-name "$(IAM_ROLE)" --assume-role-policy-document "$(ASSUME_ROLE_POLICY)" >/dev/null
	@aws iam attach-role-policy --role-name "$(IAM_ROLE)" --policy-arn $(IAM_POLICY_ARN) >/dev/null
	@echo "The '$(IAM_ROLE) role has been created. Use '$(IAM_ROLE)' anywhere an assumed role is required."

## Destroy the temporary IAM role for bootstrapping
delete/iam-role:
	@aws iam detach-role-policy --role-name "$(IAM_ROLE)" --policy-arn $(IAM_POLICY_ARN) >/dev/null
	@aws iam delete-role --role-name "$(IAM_ROLE)" > /dev/null
	@echo "The '$(IAM_ROLE)' role has been deleted"


