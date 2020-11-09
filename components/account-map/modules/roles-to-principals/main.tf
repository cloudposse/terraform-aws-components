locals {
  principals = distinct(compact(flatten([for acct, v in var.role_map : (
    contains(v, "*") ? [data.terraform_remote_state.account_map.outputs.full_account_map[acct]] :
    [
      for role in v : format(var.iam_role_arn_template,
        data.terraform_remote_state.account_map.outputs.full_account_map[acct],
        module.this.namespace,
        module.this.environment,
        acct,
        role
      )
    ]
  )])))
}
