locals {
  enabled = module.this.enabled

  allowed_roles      = concat(module.allowed_role_map.principals, module.allowed_role_map.permission_set_arn_like)
  allowed_principals = sort(var.allowed_principal_arns)
  allowed_account_names = compact(concat(
    [for k, v in var.allowed_roles : k if length(v) > 0],
    [for k, v in var.allowed_permission_sets : k if length(v) > 0]
  ))
  allowed_mapped_accounts     = [for acct in local.allowed_account_names : module.allowed_role_map.full_account_map[acct]]
  allowed_principals_accounts = data.aws_arn.allowed[*].account
  # allowed_accounts        = sort(distinct(concat(local.allowed_mapped_accounts, local.allowed_arn_accounts)))

  denied_principals      = sort(distinct(concat(var.denied_principal_arns, module.denied_role_map.principals, module.denied_role_map.permission_set_arn_like)))
  denied_mapped_accounts = [for acct in concat(keys(var.denied_roles), keys(var.denied_permission_sets)) : module.denied_role_map.full_account_map[acct]]
  denied_arn_accounts    = data.aws_arn.denied[*].account
  denied_accounts        = sort(distinct(concat(local.denied_mapped_accounts, local.denied_arn_accounts)))

  undenied_principals = sort(tolist(setsubtract(toset(local.allowed_principals), toset(local.denied_principals))))
  assume_role_enabled = (length(local.allowed_mapped_accounts) + length(local.allowed_principals_accounts) + length(local.denied_accounts)) > 0

  aws_partition = module.allowed_role_map.aws_partition
}

data "aws_arn" "allowed" {
  count = local.enabled ? length(var.allowed_principal_arns) : 0
  arn   = var.allowed_principal_arns[count.index]
}

data "aws_arn" "denied" {
  count = local.enabled ? length(var.denied_principal_arns) : 0
  arn   = var.denied_principal_arns[count.index]
}


module "allowed_role_map" {
  source = "../../../account-map/modules/roles-to-principals"

  privileged         = var.privileged
  role_map           = var.allowed_roles
  permission_set_map = var.allowed_permission_sets

  context = module.this.context
}


module "denied_role_map" {
  source = "../../../account-map/modules/roles-to-principals"

  privileged         = var.privileged
  role_map           = var.denied_roles
  permission_set_map = var.denied_permission_sets

  context = module.this.context
}


data "aws_iam_policy_document" "assume_role" {
  count = local.enabled && local.assume_role_enabled ? 1 : 0

  dynamic "statement" {
    for_each = length(local.allowed_mapped_accounts) > 0 && length(local.allowed_roles) > 0 ? ["accounts-roles"] : []

    content {
      sid = "RoleAssumeRole"

      effect = "Allow"
      actions = [
        "sts:AssumeRole",
        "sts:SetSourceIdentity",
        "sts:TagSession",
      ]

      condition {
        test     = "StringEquals"
        variable = "aws:PrincipalType"
        values   = compact(concat(["AssumedRole"], var.iam_users_enabled ? ["User"] : []))
      }
      condition {
        test     = "ArnLike"
        variable = "aws:PrincipalArn"
        values   = local.allowed_roles
      }

      principals {
        type = "AWS"
        # Principals is a required field, so we allow any principal in any of the accounts, restricted by the assumed Role ARN in the condition clauses.
        # This allows us to allow non-existent (yet to be created) roles, which would not be allowed if directly specified in `principals`.
        identifiers = formatlist("arn:${local.aws_partition}:iam::%s:root", local.allowed_mapped_accounts)
      }
    }
  }

  dynamic "statement" {
    for_each = length(local.allowed_principals_accounts) > 0 && length(local.allowed_principals) > 0 ? ["accounts-principals"] : []

    content {
      sid = "PrincipalAssumeRole"

      effect = "Allow"
      actions = [
        "sts:AssumeRole",
        "sts:SetSourceIdentity",
        "sts:TagSession",
      ]

      condition {
        test     = "ArnLike"
        variable = "aws:PrincipalArn"
        values   = local.allowed_principals
      }

      principals {
        type = "AWS"
        # Principals is a required field, so we allow any principal in any of the accounts, restricted by the assumed Role ARN in the condition clauses.
        # This allows us to allow non-existent (yet to be created) roles, which would not be allowed if directly specified in `principals`.
        identifiers = formatlist("arn:${local.aws_partition}:iam::%s:root", local.allowed_principals_accounts)
      }
    }
  }
  # As a safety measure, we do not allow AWS Users (not Roles) to assume the SAML Teams or Team roles
  # unless `deny_all_iam_users` is explicitly set to `false` or the user is explicitly allowed.
  statement {
    sid = "RoleDenyAssumeRole"

    effect = "Deny"
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:TagSession",
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values = compact(concat(local.denied_principals, var.iam_users_enabled ? [] : [
        "arn:${local.aws_partition}:iam::*:user/*"
      ]))
    }

    dynamic "condition" {
      for_each = length(local.undenied_principals) > 0 ? ["exceptions"] : []

      content {
        test     = "ArnNotEquals"
        variable = "aws:PrincipalArn"
        values   = local.undenied_principals
      }
    }

    principals {
      # By specifying type "AWS", this DENY policy will not apply to AWS Services or EKS' OIDC.
      type = "AWS"
      # Principals is a required field, so we allow any principal in any of the accounts, restricted by the assumed Role ARN in the condition clauses.
      # This allows us to allow non-existent (yet to be created) roles, which would not be allowed if directly specified in `principals`.
      # We also deny all directly logged-in users from all the enabled accounts.
      identifiers = formatlist("arn:${local.aws_partition}:iam::%s:root", sort(distinct(concat(local.denied_accounts, local.allowed_mapped_accounts, local.allowed_principals_accounts))))
    }
  }
}
