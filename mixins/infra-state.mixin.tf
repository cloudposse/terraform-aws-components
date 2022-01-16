# <-- BEGIN DOC -->
#
# This mixin is meant to be placed in a Terraform configuration outside the organization's infrastructure monorepo in order to:
#
# 1. Instantiate an AWS Provider using roles managed by the infrastructure monorepo. This is required because Cloud Posse's `providers.tf` pattern
#    requires an invocation of the `account-map` component’s `iam-roles` submodule, which is not present in a repository
#    outside of the infrastructure monorepo.
# 2. Retrieve outputs from a component in the infrastructure monorepo. This is required because Cloud Posse’s `remote-state` module expects
#    a `stacks` directory, which will not be present in other repositories, the monorepo must be cloned via a `monorepo` module
#    instantiation.
#
# Because the source attribute in the `monorepo` and `remote-state` modules cannot be interpolated and refers to a monorepo
# in a given organization, the following dummy placeholders have been put in place upstream and need to be replaced accordingly
# when "dropped into" a Terraform configuration:
#
# 1. Infrastructure monorepo: `github.com/ACME/infrastructure`
# 2. Infrastructure monorepo ref: `0.1.0`
#
# <-- END DOC -->
module "monorepo" {
  source = "git::https://github.com/ACME/infrastructure.git?ref=0.1.0"
}

locals {
  monorepo_local_path     = "${path.module}/.terraform/modules/monorepo"
  stack_config_local_path = "${local.monorepo_local_path}/stacks"
}

provider "aws" {
  region = var.region

  profile = module.iam_roles.profiles_enabled ? coalesce(var.import_profile_name, module.iam_roles.terraform_profile_name) : null
  dynamic "assume_role" {
    for_each = module.iam_roles.profiles_enabled ? [] : ["role"]
    content {
      role_arn = coalesce(var.import_role_arn, module.iam_roles.terraform_role_arn)
    }
  }
}

module "iam_roles" {
  # https://www.terraform.io/docs/language/modules/sources.html#modules-in-package-sub-directories
  source                  = "git::https://github.com/ACME/infrastructure.git//components/terraform/account-map/modules/iam-roles?ref=0.1.0"
  stack_config_local_path = local.stack_config_local_path
  context                 = module.this.context
}

variable "import_profile_name" {
  type        = string
  default     = null
  description = "AWS Profile name to use when importing a resource"
}

variable "import_role_arn" {
  type        = string
  default     = null
  description = "IAM Role ARN to use when importing a resource"
}

variable "region" {
  description = "AWS Region"
  type        = string
}
