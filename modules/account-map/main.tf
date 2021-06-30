data "aws_organizations_organization" "organization" {}

locals {
  full_account_map = {
    for acct in data.aws_organizations_organization.organization.accounts
    : acct.name == var.root_account_aws_name ? var.root_account_stage_name : acct.name => acct.id
  }

  eks_accounts     = module.accounts.outputs.eks_accounts
  non_eks_accounts = module.accounts.outputs.non_eks_accounts
  all_accounts     = concat(local.eks_accounts, local.non_eks_accounts)

  terraform_roles = {
    for name, id in local.full_account_map : name => format(var.iam_role_arn_template,
      id,
      module.this.namespace,
      module.this.environment,
      name,
      (contains([
        var.root_account_stage_name,
        var.identity_account_stage_name
      ], name) ? "admin" : "terraform")
    )
  }

  terraform_profiles = {
    for name, id in local.full_account_map : name => format(var.profile_template,
      module.this.namespace,
      module.this.environment,
      name,
      (contains([
        var.root_account_stage_name,
        var.identity_account_stage_name
      ], name) ? "admin" : "terraform")
    )
  }

  helm_roles = {
    for name, id in local.full_account_map : name => format(var.iam_role_arn_template,
      id,
      module.this.namespace,
      module.this.environment,
      name,
      (contains([
        var.root_account_stage_name,
        var.identity_account_stage_name
      ], name) ? "admin" : "helm")
    )
  }

  helm_profiles = {
    for name, id in local.full_account_map : name => format(var.profile_template,
      module.this.namespace,
      module.this.environment,
      name,
      (contains([
        var.root_account_stage_name,
        var.identity_account_stage_name
      ], name) ? "admin" : "helm")
    )
  }

  cicd_roles = {
    for name, id in local.full_account_map : name => format(var.iam_role_arn_template,
      id,
      module.this.namespace,
      var.global_environment_name,
      name,
      (contains([
        var.root_account_stage_name
      ], name) ? "admin" : "cicd")
    )
  }

  cicd_profiles = {
    for name, id in local.full_account_map : name => format(var.profile_template,
      module.this.namespace,
      var.global_environment_name,
      name,
      (contains([
        var.root_account_stage_name
      ], name) ? "admin" : "cicd")
    )
  }
}
