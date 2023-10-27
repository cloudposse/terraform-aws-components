locals {
  access_roles = local.enabled && var.access_roles_enabled ? {
    for k, v in var.access_roles : (
      length(split(module.this.delimiter, k)) > 1 ? k : module.label[k].id
    ) => v
  } : {}
  access_roles_enabled = module.this.enabled && length(keys(local.access_roles)) > 0

  caller_arn = coalesce(data.awsutils_caller_identity.current.eks_role_arn, data.awsutils_caller_identity.current.arn)
}

data "awsutils_caller_identity" "current" {}


module "label" {
  for_each = var.access_roles
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
  for_each = local.access_roles
  source   = "../account-map/modules/team-assume-role-policy"

  allowed_roles = each.value.allowed_roles
  denied_roles  = each.value.denied_roles

  # Allow whatever user or role is running Terraform to manage the backend to assume any backend access role
  allowed_principal_arns = concat(each.value.allowed_principal_arns, [local.caller_arn])
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
  assume_role_policy = module.assume_role[each.key].policy_document
  tags               = merge(module.this.tags, { Name = each.key })

  inline_policy {
    name   = each.key
    policy = data.aws_iam_policy_document.tfstate[each.key].json
  }
  managed_policy_arns = []
}
