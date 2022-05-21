locals {
  billing_read_only_policy_enabled = contains(local.configured_policies, "billing_read_only")
  billing_admin_policy_enabled     = contains(local.configured_policies, "billing_admin")
}

# Billing Read-Only Policies / Roles
data "aws_iam_policy" "aws_billing_read_only_access" {
  count = local.billing_read_only_policy_enabled ? 1 : 0

  arn = "arn:${local.aws_partition}:iam::aws:policy/AWSBillingReadOnlyAccess"
}

resource "aws_iam_policy" "billing_read_only" {
  count = local.billing_read_only_policy_enabled ? 1 : 0

  name   = format("%s-billing", module.this.id)
  policy = data.aws_iam_policy.aws_billing_read_only_access[0].policy

  tags = module.this.tags
}

# Billing Admin Policies / Roles
data "aws_iam_policy" "aws_billing_admin_access" {
  count = local.billing_admin_policy_enabled ? 1 : 0

  arn = "arn:${local.aws_partition}:iam::aws:policy/job-function/Billing"
}

data "aws_iam_policy_document" "billing_admin_access_aggregated" {
  count = local.billing_admin_policy_enabled ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy.aws_billing_admin_access[0].policy,
    data.aws_iam_policy.aws_support_access[0].policy, # Include support access for the billing role, defined in `support-policy.tf`
  ]
}

resource "aws_iam_policy" "billing_admin" {
  count = local.billing_admin_policy_enabled ? 1 : 0

  name   = format("%s-billing-admin", module.this.id)
  policy = data.aws_iam_policy_document.billing_admin_access_aggregated[0].json

  tags = module.this.tags
}
