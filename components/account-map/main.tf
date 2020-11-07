# This is an information only project, that simply populates Terraform state
# with information other modules need.

data "aws_organizations_organization" "organization" {}

locals {
  full_account_map = {
    for acct in data.aws_organizations_organization.organization.accounts : acct.name => acct.id
  }

  corp_eks_accounts     = data.terraform_remote_state.accounts.outputs.corp_eks_accounts
  corp_non_eks_accounts = data.terraform_remote_state.accounts.outputs.corp_non_eks_accounts
  corp_accounts         = concat(local.corp_eks_accounts, local.corp_non_eks_accounts)

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
}
