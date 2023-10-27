provider "aws" {
  region = var.region

  assume_role {
    # WARNING:
    #   The EKS cluster is owned by the role that created it, and that
    #   role is the only role that can access the cluster without an
    #   entry in the auth-map ConfigMap, so it is crucial it is created
    #   with the provisioned Terraform role and not an SSO role that could
    #   be removed without notice.
    #
    # This should only be run using the target account's Terraform role.
    role_arn = module.iam_roles.terraform_role_arn
  }
}

module "iam_roles" {
  source = "../../account-map/modules/iam-roles"

  profiles_enabled = false

  context = module.this.context
}
