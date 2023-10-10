
data "awsutils_caller_identity" "current" {
  count = local.dynamic_terraform_role_enabled ? 1 : 0
  # Avoid conflict with caller's provider which is using this module's output to assume a role.
  provider = awsutils.iam-roles
}

module "always" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # account_map must always be enabled, even for components that are disabled
  enabled = true

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  privileged  = var.privileged
  tenant      = var.overridable_global_tenant_name
  environment = var.overridable_global_environment_name
  stage       = var.overridable_global_stage_name

  context = module.always.context
}

locals {
  profiles_enabled = coalesce(var.profiles_enabled, local.account_map.profiles_enabled)

  account_map  = module.account_map.outputs
  account_name = lookup(module.always.descriptors, "account_name", module.always.stage)
  account_org_role_arn = local.account_name == local.account_map.root_account_account_name ? null : format(
    "arn:%s:iam::%s:role/OrganizationAccountAccessRole", local.account_map.aws_partition,
    local.account_map.full_account_map[local.account_name]
  )

  dynamic_terraform_role_enabled = try(local.account_map.terraform_dynamic_role_enabled, false)

  static_terraform_role  = local.account_map.terraform_roles[local.account_name]
  dynamic_terraform_role = try(local.dynamic_terraform_role_map[local.dynamic_terraform_role_type], null)

  current_user_role_arn       = coalesce(one(data.awsutils_caller_identity.current[*].eks_role_arn), one(data.awsutils_caller_identity.current[*].arn), "disabled")
  dynamic_terraform_role_type = try(local.account_map.terraform_access_map[local.current_user_role_arn][local.account_name], "none")

  current_identity_account = local.dynamic_terraform_role_enabled ? split(":", local.current_user_role_arn)[4] : ""
  is_root_user             = local.current_identity_account == local.account_map.full_account_map[local.account_map.root_account_account_name]
  is_target_user           = local.current_identity_account == local.account_map.full_account_map[local.account_name]

  dynamic_terraform_role_map = local.dynamic_terraform_role_enabled ? {
    apply = format(local.account_map.iam_role_arn_templates[local.account_name], local.account_map.terraform_role_name_map["apply"])
    plan  = format(local.account_map.iam_role_arn_templates[local.account_name], local.account_map.terraform_role_name_map["plan"])
    # For user without explicit permissions:
    #   If the current user is a user in the `root` account, assume the `OrganizationAccountAccessRole` role in the target account.
    #   If the current user is a user in the target account, do not assume a role at all, let them do what their role allows.
    #   Otherwise, force them into the static Terraform role for the target account,
    #   to prevent users from accidentally running Terraform in the wrong account.
    none = local.is_root_user ? local.account_org_role_arn : (
      # null means use current user's role
      local.is_target_user ? null : local.static_terraform_role
    )
  } : {}

  final_terraform_role_arn = local.profiles_enabled ? null : (
    local.dynamic_terraform_role_enabled ? local.dynamic_terraform_role : local.static_terraform_role
  )

  final_terraform_profile_name = local.profiles_enabled ? local.account_map.profiles[local.account_name] : null
}
