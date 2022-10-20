module "org_account_access_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.16.2"

  name = "OrganizationAccountAccessRole"

  # Don't use context components in the role name.
  use_fullname         = false
  label_value_case     = "none"
  max_session_duration = 3600

  role_description = <<EOT
  Organization access role. This account was imported, which resulted in this role needing to be provisioned via Terraform.
  This role is only assumable by the OrgAdmin user or role from the management account (i.e. var.org_admin_arn).
  Provides full administrator access.
  EOT

  # Roles/users allowed to assume role
  principals = {
    AWS = [var.org_admin_arn]
  }

  # This is a critical admin role, so we keep it locked down and enforce MFA
  assume_role_conditions = [{
    test     = "Bool"
    variable = "aws:MultiFactorAuthPresent"
    values   = ["true"]
  }]

  policy_document_count = 0
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  context = module.this.context
}
