variable "manage_secrets" {
  type        = bool
  description = "Whether to manage secrets or not"
  default     = true
}

variable "ecr_component_name" {
  type        = string
  description = "The name of the ECR component"
  default     = "ecr"
}

variable "ecr_stage_name" {
  type        = string
  description = "The name of the stage where the ECR component is deployed"
  default     = "artifacts"
}

variable "ecr_environment_name" {
  type        = string
  description = "The name of the environment where the ECR component is deployed. Defaults to `module.this.environment`"
  default     = null
}

variable "ecr_region" {
  type        = string
  description = "The name of the ECR region to use for the ECR registry. Defaults to `var.region`"
  default     = null
}

resource "random_password" "action_passphrase" {
  length = 40
}

module "ecr" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = var.ecr_component_name
  stage       = var.ecr_stage_name
  environment = var.ecr_environment_name

  context = module.this.context
}

locals {
  secrets = {
    PRIVATE_REPO_ACCESS_TOKEN    = join("", data.aws_ssm_parameter.github_api_key.*.value)
    GHA_SECRET_OUTPUT_PASSPHRASE = random_password.action_passphrase.result
    ECR_REGISTRY                 = module.ecr.outputs.repository_host
    ECR_REGION                   = length(var.ecr_region) > 0 ? var.ecr_region : var.region
    ECR_IAM_ROLE                 = module.ecr.outputs.github_actions_iam_role_arn
  }
}

resource "github_actions_secret" "default" {
  for_each        = var.enabled && var.manage_secrets ? local.secrets : {}
  repository      = local.github_repository.name
  secret_name     = each.key
  plaintext_value = each.value
}
