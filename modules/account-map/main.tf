data "aws_organizations_organization" "organization" {}

data "aws_partition" "current" {}

locals {
  aws_partition = data.aws_partition.current.partition

  full_account_map = {
    for acct in data.aws_organizations_organization.organization.accounts
    : acct.name == var.root_account_aws_name ? var.root_account_account_name : acct.name => acct.id
  }

  iam_role_arn_templates = {
    for name, info in local.account_info_map : name => format(var.iam_role_arn_template_template, compact(
      [
        local.aws_partition,
        info.id,
        module.this.namespace,
        lookup(info, "tenant", ""),
        module.this.environment,
        info.stage
      ]
    )...)

  }

  eks_accounts     = module.accounts.outputs.eks_accounts
  non_eks_accounts = module.accounts.outputs.non_eks_accounts
  all_accounts     = concat(local.eks_accounts, local.non_eks_accounts)
  account_info_map = module.accounts.outputs.account_info_map

  # We should move this to be specified by tags on the accounts,
  # like we do with EKS, but for now....
  account_role_map = {
    artifacts = var.artifacts_account_account_name
    audit     = var.audit_account_account_name
    dns       = var.dns_account_account_name
    identity  = var.identity_account_account_name
    root      = var.root_account_account_name
  }

  account_profiles = {
    # dropping the role name from the profile, especially with trimsuffix(),
    # is a hack for expedience while we work out the kinks in the
    # aws-config file automatic generation and related issues.
    # The proper solution will probably come out of the null-label v2
    # which should have an account_long_name output.
    for name, info in local.account_info_map : name => trimsuffix(format(var.profile_template, compact(
      [
        module.this.namespace,
        lookup(info, "tenant", ""),
        module.this.environment,
        info.stage, "~"
      ]
    )...), "-~")
  }


  terraform_roles = {
    for name, info in local.account_info_map : name =>
    format(local.iam_role_arn_templates[name],
      (contains([
        var.root_account_account_name,
        var.identity_account_account_name
      ], name) ? "admin" : "terraform")
    )
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
    for name, info in local.account_info_map : name =>
    format(local.iam_role_arn_templates[name],
      (contains([
        var.root_account_account_name,
        var.identity_account_account_name
      ], name) ? "admin" : "helm")
    )

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
    for name, info in local.account_info_map : name =>
    format(local.iam_role_arn_templates[name],
      (contains([
        var.root_account_account_name
      ], name) ? "admin" : "cicd")
    )
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
