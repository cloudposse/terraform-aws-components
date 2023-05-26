variable "manage_secrets" {
  type        = bool
  description = "Whether to manage secrets or not"
  default     = true
}

variable "ecr_account" {
  type        = string
  description = "The name of the ECR account to use for the ECR registry"
  default     = "artifacts"
}

variable "ecr_region" {
  type        = string
  description = "The name of the ECR region to use for the ECR registry"
  default     = "us-east-2"
}

variable "ecr_role_name" {
  type        = string
  description = "The name of the IAM role to use for the ECR registry"
  default     = "poweruser"
}

resource "random_password" "action_passphrase" {
  length = 40
}

module "ecr" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "ecr"

  context     = module.this.context
  stage       = var.ecr_account
  environment = "use2"
}

locals {
  secrets = {
    PRIVATE_REPO_ACCESS_TOKEN    = join("", data.aws_ssm_parameter.github_api_key.*.value)
    GHA_SECRET_OUTPUT_PASSPHRASE = random_password.action_passphrase.result
    ECR_REGISTRY                 = module.ecr.outputs.ecr_repo_arn_map[lower("${var.github_organization}/${var.name}")]
    ECR_REGION                   = var.ecr_region
    ECR_IAM_ROLE                 = format(module.iam_roles.iam_role_arn_template, var.ecr_role_name)
  }
}

resource "github_actions_secret" "default" {
  for_each        = var.enabled && var.manage_secrets ? local.secrets : {}
  repository      = local.github_repository.name
  secret_name     = each.key
  plaintext_value = each.value
}
