# This is split off into a separate file in the hopes we can drop it altogether in the future,
# or else move it into `roles-to-principals`.

locals {

  # EKS does not accept the actual role ARN of the permission set,
  # but instead requires the ARN of the role with the path prefix removed.
  # Unfortunately, the path prefix is not always the same.
  # Usually it is only "/aws-reserved/sso.amazonaws.com/"
  # but sometimes it includes a region, like "/aws-reserved/sso.amazonaws.com/ap-southeast-1/"
  # Adapted from https://registry.terraform.io/providers/hashicorp/aws/3.75.1/docs/data-sources/iam_roles#role-arns-with-paths-removed
  aws_sso_permission_set_to_eks_role_arn_map = { for k, v in data.aws_iam_roles.sso_roles : k => [
    for parts in [split("/", one(v.arns[*]))] :
    format("%s/%s", parts[0], element(parts, length(parts) - 1))
  ][0] }

  aws_sso_iam_roles_auth = [for role in var.aws_sso_permission_sets_rbac : {
    rolearn  = local.aws_sso_permission_set_to_eks_role_arn_map[role.aws_sso_permission_set]
    username = format("%s-%s", local.this_account_name, role.aws_sso_permission_set)
    groups   = role.groups
  }]
}

data "aws_iam_roles" "sso_roles" {
  for_each    = toset(var.aws_sso_permission_sets_rbac[*].aws_sso_permission_set)
  name_regex  = format("AWSReservedSSO_%s_.*", each.value)
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}
