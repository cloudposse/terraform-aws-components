
# This file generates a permission set for each role specified in var.target_identity_roles
# which is named "Identity<Role>TeamAccess" and grants access to only that role,
# plus ViewOnly access because it is difficult to navigate without any access at all.

locals {
  identity_account = module.account_map.outputs.full_account_map[module.account_map.outputs.identity_account_account_name]
}

module "role_prefix" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  stage = var.aws_teams_stage_name

  context = module.this.context
}

data "aws_iam_policy_document" "assume_aws_team" {
  for_each = local.enabled ? var.aws_teams_accessible : []

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
  identity_access_permission_sets = [for role in var.aws_teams_accessible : {
    name                                = format("Identity%sTeamAccess", replace(title(role), "-", "")),
    description                         = format("Allow user to assume the %s Team role in the Identity account, which allows access to other accounts", replace(title(role), "-", ""))
    relay_state                         = "",
    session_duration                    = "",
    tags                                = {},
    inline_policy                       = data.aws_iam_policy_document.assume_aws_team[role].json
    policy_attachments                  = ["arn:${local.aws_partition}:iam::aws:policy/job-function/ViewOnlyAccess"]
    customer_managed_policy_attachments = []
  }]
}
