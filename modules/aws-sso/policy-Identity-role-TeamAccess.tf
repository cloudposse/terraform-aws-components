
# This file generates a permission set for each role specified in var.target_identity_roles
# which is named "Identity<Role>TeamAccess" and grants access to only that role,
# plus ViewOnly access because it is difficult to navigate without any access at all.

data "aws_iam_policy_document" "assume_aws_team" {
  for_each = local.enabled ? var.aws_teams_accessible : []

  statement {
    sid = "RoleAssumeRole"

    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:TagSession",
    ]

    resources = ["*"]

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

module "role_map" {
  source = "../account-map/modules/roles-to-principals"

  teams      = var.aws_teams_accessible
  privileged = var.privileged

  context = module.this.context
}

locals {
  identity_access_permission_sets = [for role in var.aws_teams_accessible : {
    name                                = module.role_map.team_permission_set_name_map[role],
    description                         = format("Allow user to assume the %s Team role in the Identity account, which allows access to other accounts", replace(title(role), "-", ""))
    relay_state                         = "",
    session_duration                    = "",
    tags                                = {},
    inline_policy                       = data.aws_iam_policy_document.assume_aws_team[role].json
    policy_attachments                  = ["arn:${local.aws_partition}:iam::aws:policy/job-function/ViewOnlyAccess"]
    customer_managed_policy_attachments = []
  }]
}
