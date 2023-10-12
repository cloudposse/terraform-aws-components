output "root_account_aws_name" {
  value       = var.root_account_aws_name
  description = "The name of the root account as reported by AWS"
}

output "root_account_account_name" {
  value       = var.root_account_account_name
  description = "The short name for the root account"
}

output "identity_account_account_name" {
  value       = var.identity_account_account_name
  description = "The short name for the account holding primary IAM roles"
}

output "dns_account_account_name" {
  value       = var.dns_account_account_name
  description = "The short name for the primary DNS account"
}

output "artifacts_account_account_name" {
  value       = var.artifacts_account_account_name
  description = "The short name for the artifacts account"
}

output "audit_account_account_name" {
  value       = var.audit_account_account_name
  description = "The short name for the audit account"
}

output "org" {
  value       = data.aws_organizations_organization.organization
  description = "The name of the AWS Organization"
}

output "aws_partition" {
  value       = local.aws_partition
  description = "The AWS \"partition\" to use when constructing resource ARNs"
}

output "account_info_map" {
  value       = local.account_info_map
  description = <<-EOT
    A map from account name to various information about the account.
    See the `account_info_map` output of `account` for more detail.
    EOT
}

output "full_account_map" {
  value       = local.full_account_map
  description = "The map of account name to account ID (number)."
}

output "eks_accounts" {
  value       = local.eks_accounts
  description = "A list of all accounts in the AWS Organization that contain EKS clusters"
}

output "non_eks_accounts" {
  value       = local.non_eks_accounts
  description = "A list of all accounts in the AWS Organization that do not contain EKS clusters"
}

output "all_accounts" {
  value       = local.all_accounts
  description = "A list of all accounts in the AWS Organization"
}

output "iam_role_arn_templates" {
  value       = local.iam_role_arn_templates
  description = "Map of accounts to corresponding IAM Role ARN templates"
}

output "terraform_roles" {
  value       = local.terraform_roles
  description = "A list of all IAM roles used to run terraform updates"
}

output "terraform_profiles" {
  value       = local.terraform_profiles
  description = "A list of all SSO profiles used to run terraform updates"
}

output "profiles_enabled" {
  value       = var.profiles_enabled
  description = "Whether or not to enable profiles instead of roles for the backend"
}

output "terraform_dynamic_role_enabled" {
  value       = local.dynamic_role_enabled
  description = "True if dynamic role for Terraform is enabled"
  precondition {
    condition     = local.dynamic_role_enabled && var.profiles_enabled ? false : true
    error_message = "Dynamic role for Terraform cannot be used with profiles. One of `terraform_dynamic_role_enabled` or `profiles_enabled` must be false."
  }
}

output "terraform_access_map" {
  value       = local.dynamic_role_enabled ? local.role_arn_terraform_access : null
  description = <<-EOT
  Mapping of team Role ARN to map of account name to terraform action role ARN to assume

  For each team in `aws-teams`, look at every account and see if that team has access to the designated "apply" role.
    If so, add an entry `<account-name> = "apply"` to the `terraform_access_map` entry for that team.
    If not, see if it has access to the "plan" role, and if so, add a "plan" entry.
    Otherwise, no entry is added.
  EOT
}

output "terraform_role_name_map" {
  value       = local.dynamic_role_enabled ? var.terraform_role_name_map : null
  description = "Mapping of Terraform action (plan or apply) to aws-team-role name to assume for that action"
}

resource "local_file" "account_info" {
  content = templatefile("${path.module}/account-info.tftmpl", {
    account_info_map = local.account_info_map
    account_profiles = local.account_profiles
    account_role_map = local.account_role_map
    namespace        = module.this.namespace
    source_profile   = coalesce(var.aws_config_identity_profile_name, format("%s-identity", module.this.namespace))
  })
  filename = "${path.module}/account-info/${module.this.id}.sh"
}


######################
## Deprecated outputs
## These outputs are deprecated and will be removed in a future release
## As of this release, they return empty lists so as not to break old
## versions of account-map/modules/iam-roles and imposing an order
## on deploying new code vs applying the updated account-map
######################

output "helm_roles" {
  value       = local.empty_account_map
  description = "OBSOLETE: dummy results returned to avoid breaking code that depends on this output"
}

output "helm_profiles" {
  value       = local.empty_account_map
  description = "OBSOLETE: dummy results returned to avoid breaking code that depends on this output"
}

output "cicd_roles" {
  value       = local.empty_account_map
  description = "OBSOLETE: dummy results returned to avoid breaking code that depends on this output"
}

output "cicd_profiles" {
  value       = local.empty_account_map
  description = "OBSOLETE: dummy results returned to avoid breaking code that depends on this output"
}

######################
## End of Deprecated outputs
## Please add new outputs above this section
######################
