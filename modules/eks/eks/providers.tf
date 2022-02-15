provider "aws" {
  region = var.region

  assume_role {
    # `terraform import` will not use data from a data source,
    # so on import we have to explicitly specify the role
    # WARNING:
    #   The EKS cluster is owned by the role that created it, and that
    #   role is the only role that can access the cluster without an
    #   entry in the auth-map ConfigMap, so it is crucial it is created
    #   with the provisioned Terraform role and not an SSO role that could
    #   be removed without notice.
    #
    # i.e. Only NON SSO assumed roles such as spacelift assumed roles, can
    # plan this terraform module.
    role_arn = coalesce(var.import_role_arn, module.iam_roles.terraform_role_arn)
  }
}

module "iam_roles" {
  source  = "../../account-map/modules/iam-roles"
  context = module.this.context
}

variable "import_role_arn" {
  type        = string
  default     = null
  description = "IAM Role ARN to use when importing a resource"
}
