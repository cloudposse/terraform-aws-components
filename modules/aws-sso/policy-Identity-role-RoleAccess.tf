
# This file generates a permission set for each role specified in var.target_identity_roles
# which is named "Identity<Role>RoleAccess" and grants access to only that role,
# plus ViewOnly access because it is difficult to navigate without any access at all.

locals {
  identity_account = module.account_map.outputs.full_account_map[var.iam_primary_roles_stage_name]
}

module "role_prefix" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  stage = var.iam_primary_roles_stage_name

  context = module.this.context
}

data "aws_iam_policy_document" "assume_identity_role" {
  for_each = local.enabled ? var.identity_roles_accessible : []

  statement {
    sid = "RoleAssumeRole"

    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    resources = [
      format("arn:${local.aws_partition}:iam::%s:role/%s-%s", local.identity_account, module.role_prefix.id, each.value)
    ]

    /* For future reference, this tag-based restriction also works, based on
       the fact that we always tag our IAM roles with the "Name" tag.
       This could be used to control access based on some other tag, like "Category",
       so is left here as an example.

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "iam:ResourceTag/Name"  # "Name" is the Tag Key
      values   = [format("%s-%s", module.role_prefix.id, each.value)]
    }
    resources = [
      # This allows/restricts access to only IAM roles, not users or SSO roles
      format("arn:aws:iam::%s:role/*", local.identity_account)
    ]

    */

  }
}

locals {
  identity_access_permission_sets = [for role in var.identity_roles_accessible : {
    name               = format("Identity%sRoleAccess", title(role)),
    description        = "Allow user to assume %s role in Identity account, which allows access to other accounts",
    relay_state        = "",
    session_duration   = "",
    tags               = {},
    inline_policy      = data.aws_iam_policy_document.assume_identity_role[role].json
    policy_attachments = ["arn:${local.aws_partition}:iam::aws:policy/job-function/ViewOnlyAccess"]
  }]
}
