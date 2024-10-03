locals {
  access_roles = local.enabled ? {
    for k, v in var.access_roles : (
      length(split(module.this.delimiter, k)) > 1 ? k : module.label[k].id
    ) => v
  } : {}

  access_roles_enabled      = local.enabled && var.access_roles_enabled
  cold_start_access_enabled = local.enabled && !var.access_roles_enabled

  # Technically, `eks_role_arn` is incorrect, because it strips any path from the ARN,
  # but since we do not expect there to be a path in the role ARN (as opposed to perhaps an attached IAM policy),
  # it is OK. The advantage of using `eks_role_arn` is that it converts and Assumed Role ARN from STS, like
  #    arn:aws:sts::123456789012:assumed-role/acme-core-gbl-root-admin/aws-go-sdk-1722029959251053170
  # to the IAM Role ARN, like
  #    arn:aws:iam::123456789012:role/acme-core-gbl-root-admin
  caller_arn = coalesce(data.awsutils_caller_identity.current.eks_role_arn, data.awsutils_caller_identity.current.arn)
}

data "awsutils_caller_identity" "current" {}
data "aws_partition" "current" {}


module "label" {
  for_each = local.enabled ? var.access_roles : {}
  source   = "cloudposse/label/null"
  version  = "0.25.0" # requires Terraform >= 0.13.0

  enabled = length(split(module.this.delimiter, each.key)) == 1

  environment = "gbl"
  attributes  = contains(["default", "terraform"], each.key) ? [] : [each.key]
  # Support backward compatibility with old `iam-delegated-roles`
  name = each.key == "terraform" ? "terraform" : null

  context = module.this.context
}

module "assume_role" {
  for_each = local.access_roles_enabled ? local.access_roles : {}
  source   = "../account-map/modules/team-assume-role-policy"

  allowed_roles = each.value.allowed_roles
  denied_roles  = each.value.denied_roles

  # Allow whatever user or role is running Terraform to manage the backend to assume any backend access role
  allowed_principal_arns = distinct(concat(each.value.allowed_principal_arns, [local.caller_arn]))
  denied_principal_arns  = each.value.denied_principal_arns
  # Permission sets are for AWS SSO, which is optional
  allowed_permission_sets = try(each.value.allowed_permission_sets, {})
  denied_permission_sets  = try(each.value.denied_permission_sets, {})

  privileged = true

  context = module.this.context
}

data "aws_iam_policy_document" "tfstate" {
  for_each = local.access_roles

  statement {
    sid     = "TerraformStateBackendS3Bucket"
    effect  = "Allow"
    actions = concat(["s3:ListBucket", "s3:GetObject"], each.value.write_enabled ? ["s3:PutObject", "s3:DeleteObject"] : [])
    resources = [
      module.tfstate_backend.s3_bucket_arn,
      "${module.tfstate_backend.s3_bucket_arn}/*"
    ]
  }

  statement {
    sid    = "TerraformStateBackendDynamoDbTable"
    effect = "Allow"
    # Even readers need to be able to write to the Dynamo table to lock the state while planning
    # actions   = concat(["dynamodb:GetItem"], each.value.write_enabled ? ["dynamodb:PutItem", "dynamodb:DeleteItem"] : [])
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = [module.tfstate_backend.dynamodb_table_arn]
  }
}

resource "aws_iam_role" "default" {
  for_each = local.access_roles

  name               = each.key
  description        = "${each.value.write_enabled ? "Access" : "Read-only access"} role for ${module.this.id}"
  assume_role_policy = var.access_roles_enabled ? module.assume_role[each.key].policy_document : data.aws_iam_policy_document.cold_start_assume_role[each.key].json
  tags               = merge(module.this.tags, { Name = each.key })

  inline_policy {
    name   = each.key
    policy = data.aws_iam_policy_document.tfstate[each.key].json
  }
  managed_policy_arns = []
}

locals {
  all_cold_start_access_principals = local.cold_start_access_enabled ? toset(concat([local.caller_arn],
  flatten([for k, v in local.access_roles : v.allowed_principal_arns]))) : toset([])
  cold_start_access_principal_arns = local.cold_start_access_enabled ? { for k, v in local.access_roles : k => distinct(concat(
    [local.caller_arn], v.allowed_principal_arns
  )) } : {}
  cold_start_access_principals = local.cold_start_access_enabled ? {
    for k, v in local.cold_start_access_principal_arns : k => formatlist("arn:%v:iam::%v:root", data.aws_partition.current.partition, distinct([
      for arn in v : data.aws_arn.cold_start_access[arn].account
    ]))
  } : {}

}

data "aws_arn" "cold_start_access" {
  for_each = local.all_cold_start_access_principals
  arn      = each.value
}

# This is a basic policy that allows the caller and explicitly allowed principals to assume the role
# during the period roles are being set up (cold start).
data "aws_iam_policy_document" "cold_start_assume_role" {
  for_each = local.cold_start_access_enabled ? local.access_roles : {}

  statement {
    sid = "ColdStartRoleAssumeRole"

    effect = "Allow"
    # These actions need to be kept in sync with the actions in the assume_role module
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:TagSession",
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = local.cold_start_access_principal_arns[each.key]
    }

    principals {
      type = "AWS"
      # Principals is a required field, so we allow any principal in any of the accounts, restricted by the assumed Role ARN in the condition clauses.
      # This allows us to allow non-existent (yet to be created) roles, which would not be allowed if directly specified in `principals`.
      identifiers = local.cold_start_access_principals[each.key]
    }
  }
}
