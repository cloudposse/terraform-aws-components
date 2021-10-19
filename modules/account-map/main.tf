data "aws_organizations_organization" "organization" {}

locals {
  full_account_map = {
    for acct in data.aws_organizations_organization.organization.accounts
    : acct.name == var.root_account_aws_name ? var.root_account_account_name : acct.name => acct.id
  }

  eks_accounts     = module.accounts.outputs.eks_accounts
  non_eks_accounts = module.accounts.outputs.non_eks_accounts
  all_accounts     = concat(local.eks_accounts, local.non_eks_accounts)
  account_info_map = module.accounts.outputs.account_info_map

  terraform_roles = {
    for name, info in local.account_info_map : name => format(var.iam_role_arn_template, compact(
      [
        info.id,
        module.this.namespace,
        lookup(info, "tenant", ""),
        module.this.environment,
        info.stage,
        (contains([
          var.root_account_account_name,
          var.identity_account_account_name
        ], name) ? "admin" : "terraform")
      ]
    )...)
  }

  terraform_profiles = {
    for name, info in local.account_info_map : name => format(var.profile_template, compact(
      [
        module.this.namespace,
        lookup(info, "tenant", ""),
        module.this.environment,
        info.stage,
        (contains([
          var.root_account_account_name,
          var.identity_account_account_name
        ], name) ? "admin" : "terraform")
      ]
    )...)
  }

  helm_roles = {
    for name, info in local.account_info_map : name => format(var.iam_role_arn_template, compact(
      [
        info.id,
        module.this.namespace,
        lookup(info, "tenant", ""),
        module.this.environment,
        info.stage,
        (contains([
          var.root_account_account_name,
          var.identity_account_account_name
        ], name) ? "admin" : "helm")
      ]
    )...)
  }

  helm_profiles = {
    for name, info in local.account_info_map : name => format(var.profile_template, compact(
      [
        module.this.namespace,
        lookup(info, "tenant", ""),
        module.this.environment,
        info.stage,
        (contains([
          var.root_account_account_name,
          var.identity_account_account_name
        ], name) ? "admin" : "helm")
      ]
    )...)
  }

  cicd_roles = {
    for name, info in local.account_info_map : name => format(var.iam_role_arn_template, compact(
      [
        info.id,
        module.this.namespace,
        lookup(info, "tenant", ""),
        var.global_environment_name,
        info.stage,
        (contains([
          var.root_account_account_name
        ], name) ? "admin" : "cicd")
      ]
    )...)
  }

  cicd_profiles = {
    for name, info in local.account_info_map : name => format(var.profile_template, compact(
      [
        module.this.namespace,
        lookup(info, "tenant", ""),
        var.global_environment_name,
        info.stage,
        (contains([
          var.root_account_account_name
        ], name) ? "admin" : "cicd")
      ]
    )...)
  }
}
