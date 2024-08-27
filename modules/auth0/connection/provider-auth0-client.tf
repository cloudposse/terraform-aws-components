#
# Fetch the Auth0 tenant component deployment in some stack
#
variable "auth0_tenant_component_name" {
  description = "The name of the component"
  type        = string
  default     = "auth0/tenant"
}

variable "auth0_tenant_environment_name" {
  description = "The name of the environment where the Auth0 tenant component is deployed. Defaults to the environment of the current stack."
  type        = string
  default     = ""
}

variable "auth0_tenant_stage_name" {
  description = "The name of the stage where the Auth0 tenant component is deployed. Defaults to the stage of the current stack."
  type        = string
  default     = ""
}

variable "auth0_tenant_tenant_name" {
  description = "The name of the tenant where the Auth0 tenant component is deployed. Yes this is a bit redundant, since Auth0 also calls this resource a tenant. Defaults to the tenant of the current stack."
  type        = string
  default     = ""
}

locals {
  auth0_tenant_environment_name = length(var.auth0_tenant_environment_name) > 0 ? var.auth0_tenant_environment_name : module.this.environment
  auth0_tenant_stage_name       = length(var.auth0_tenant_stage_name) > 0 ? var.auth0_tenant_stage_name : module.this.stage
  auth0_tenant_tenant_name      = length(var.auth0_tenant_tenant_name) > 0 ? var.auth0_tenant_tenant_name : module.this.tenant
}

module "auth0_tenant" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.enabled ? 1 : 0

  component = var.auth0_tenant_component_name

  environment = local.auth0_tenant_environment_name
  stage       = local.auth0_tenant_stage_name
  tenant      = local.auth0_tenant_tenant_name
}

#
# Set up the AWS provider to access AWS SSM parameters in the same account as the Auth0 tenant
#

provider "aws" {
  alias  = "auth0_provider"
  region = var.region

  # Profile is deprecated in favor of terraform_role_arn. When profiles are not in use, terraform_profile_name is null.
  profile = module.iam_roles_auth0_provider.terraform_profile_name

  dynamic "assume_role" {
    # module.iam_roles_auth0_provider.terraform_role_arn may be null, in which case do not assume a role.
    for_each = compact([module.iam_roles_auth0_provider.terraform_role_arn])
    content {
      role_arn = assume_role.value
    }
  }
}

module "iam_roles_auth0_provider" {
  source = "../../account-map/modules/iam-roles"

  environment = local.auth0_tenant_environment_name
  stage       = local.auth0_tenant_stage_name
  tenant      = local.auth0_tenant_tenant_name

  context = module.this.context
}

data "aws_ssm_parameter" "auth0_domain" {
  provider = aws.auth0_provider
  name     = module.auth0_tenant[0].outputs.domain_ssm_path
}

data "aws_ssm_parameter" "auth0_client_id" {
  provider = aws.auth0_provider
  name     = module.auth0_tenant[0].outputs.client_id_ssm_path
}

data "aws_ssm_parameter" "auth0_client_secret" {
  provider = aws.auth0_provider
  name     = module.auth0_tenant[0].outputs.client_secret_ssm_path
}

#
# Initialize the Auth0 provider with the Auth0 domain, client ID, and client secret from that deployment
#

variable "auth0_debug" {
  type        = bool
  description = "Enable debug mode for the Auth0 provider"
  default     = true
}

provider "auth0" {
  domain        = data.aws_ssm_parameter.auth0_domain.value
  client_id     = data.aws_ssm_parameter.auth0_client_id.value
  client_secret = data.aws_ssm_parameter.auth0_client_secret.value
  debug         = var.auth0_debug
}

#
# Finally if enabled, create a duplicate of the AWS SSM parameters for Auth0 in this account.
#
variable "create_auth0_ssm_parameters_enabled" {
  description = "Whether or not to create a duplicate of the AWS SSM parameter for the Auth0 domain, client ID, and client secret in this account."
  type        = bool
  default     = false
}

module "auth0_ssm_parameters" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.13.0"

  enabled = local.enabled && var.create_auth0_ssm_parameters_enabled

  parameter_write = [
    {
      name        = module.auth0_tenant[0].outputs.domain_ssm_path
      value       = data.aws_ssm_parameter.auth0_domain.value
      type        = "SecureString"
      overwrite   = "true"
      description = "Auth0 domain value for the Auth0 ${local.auth0_tenant_tenant_name}-${local.auth0_tenant_environment_name}-${local.auth0_tenant_stage_name} tenant"
    },
    {
      name        = module.auth0_tenant[0].outputs.client_id_ssm_path
      value       = data.aws_ssm_parameter.auth0_client_id.value
      type        = "SecureString"
      overwrite   = "true"
      description = "Auth0 client ID for the Auth0 ${local.auth0_tenant_tenant_name}-${local.auth0_tenant_environment_name}-${local.auth0_tenant_stage_name} tenant"
    },
    {
      name        = module.auth0_tenant[0].outputs.client_secret_ssm_path
      value       = data.aws_ssm_parameter.auth0_client_secret.value
      type        = "SecureString"
      overwrite   = "true"
      description = "Auth0 client secret for the Auth0 ${local.auth0_tenant_tenant_name}-${local.auth0_tenant_environment_name}-${local.auth0_tenant_stage_name} tenant"
    },
  ]

  context = module.this.context
}
