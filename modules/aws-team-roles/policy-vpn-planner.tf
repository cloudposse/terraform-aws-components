locals {
  vpn_planner_enabled = contains(local.configured_policies, "vpn_planner")
}

data "aws_iam_policy_document" "vpn_planner_access" {
  count = local.vpn_planner_enabled ? 1 : 0

  statement {
    sid    = "AllowVPNReader"
    effect = "Allow"
    actions = [
      "ec2:ExportClientVpnClientConfiguration",
    ]
    resources = [
      "*"
    ]
  }

}

data "aws_iam_policy_document" "vpn_planner_access_aggregated" {
  count = local.vpn_planner_enabled ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy_document.vpn_planner_access[0].json,
  ]
}

resource "aws_iam_policy" "vpn_planner" {
  count = local.vpn_planner_enabled ? 1 : 0

  name   = format("%s-vpn_planner", module.this.id)
  policy = data.aws_iam_policy_document.vpn_planner_access_aggregated[0].json

  tags = module.this.tags
}
