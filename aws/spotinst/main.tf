provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "aws" {
  alias  = "spotinst"
  region = "us-east-1"

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

locals {
  template_url = "https://s3.amazonaws.com/spotinst-public/assets/cloudformation/templates/spotinst_aws_cfn_account_credentials_iam_stack.template.json"
  parameters = {
    AccountId  = module.account_id.value
    ExternalId = module.external_id.value
    Principal  = module.principal.value
    Token      = module.token.value
  }
}

module "account_id" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-chamber-reader.git?ref=tags/0.1.0"

  enabled         = var.enabled
  chamber_format  = var.chamber_format
  chamber_service = var.chamber_service
  parameter       = var.chamber_name_account_id
  override_value  = var.override_account_id
}

module "external_id" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-chamber-reader.git?ref=tags/0.1.0"

  enabled         = var.enabled
  chamber_format  = var.chamber_format
  chamber_service = var.chamber_service
  parameter       = var.chamber_name_external_id
  override_value  = var.override_external_id
}

module "principal" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-chamber-reader.git?ref=tags/0.1.0"

  enabled         = var.enabled
  chamber_format  = var.chamber_format
  chamber_service = var.chamber_service
  parameter       = var.chamber_name_principal
  override_value  = var.override_principal
}

module "token" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-chamber-reader.git?ref=tags/0.1.0"

  enabled         = var.enabled
  chamber_format  = var.chamber_format
  chamber_service = var.chamber_service
  parameter       = var.chamber_name_token
  override_value  = var.override_token
}

module "default" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudformation-stack.git?ref=tags/0.1.0"

  providers = {
    aws = aws.spotinst
  }

  enabled      = var.enabled
  namespace    = var.namespace
  stage        = var.stage
  name         = var.name
  attributes   = var.attributes
  parameters   = local.parameters
  template_url = local.template_url
  capabilities = var.capabilities
}

