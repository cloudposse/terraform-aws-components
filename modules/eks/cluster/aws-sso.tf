# This is split off into a separate file in the hopes we can drop it altogether in the future,
# or else move it into `roles-to-principals`.

locals {

  aws_sso_access_entry_map = {
    for role in var.aws_sso_permission_sets_rbac : tolist(data.aws_iam_roles.sso_roles[role.aws_sso_permission_set].arns)[0] => {
      kubernetes_groups = role.groups
    }
  }
}

data "aws_iam_roles" "sso_roles" {
  for_each    = toset(var.aws_sso_permission_sets_rbac[*].aws_sso_permission_set)
  name_regex  = format("AWSReservedSSO_%s_.*", each.value)
  path_prefix = "/aws-reserved/sso.amazonaws.com/"

  lifecycle {
    postcondition {
      condition = length(self.arns) == 1
      error_message = length(self.arns) == 0 ? "Could not find Role ARN for the AWS SSO permission set: ${each.value}" : (
        "Found more than one (${length(self.arns)}) Role ARN for the AWS SSO permission set: ${each.value}"
      )
    }
  }
}
