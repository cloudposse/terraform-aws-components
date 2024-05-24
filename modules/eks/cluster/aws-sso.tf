# This is split off into a separate file in the hopes we can drop it altogether in the future,
# or else move it into `roles-to-principals`.

locals {

  aws_sso_access_entry_map = {
    for role in var.aws_sso_permission_sets_rbac : data.aws_iam_roles.sso_roles[role.aws_sso_permission_set] => {
      kubernetes_groups = role.groups
    }
  }
}

data "aws_iam_roles" "sso_roles" {
  for_each    = toset(var.aws_sso_permission_sets_rbac[*].aws_sso_permission_set)
  name_regex  = format("AWSReservedSSO_%s_.*", each.value)
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}
