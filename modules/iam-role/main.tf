locals {
  enabled = module.this.enabled
}

module "role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.17.0"

  assume_role_actions      = var.assume_role_actions
  assume_role_conditions   = var.assume_role_conditions
  instance_profile_enabled = var.instance_profile_enabled
  managed_policy_arns      = var.managed_policy_arns
  max_session_duration     = var.max_session_duration
  path                     = var.path
  permissions_boundary     = var.permissions_boundary
  policy_description       = var.policy_description
  policy_document_count    = var.policy_document_count
  policy_documents         = var.policy_documents
  policy_name              = var.policy_name
  principals               = var.principals
  role_description         = var.role_description
  tags_enabled             = var.tags_enabled
  use_fullname             = var.use_fullname

  context = module.this.context
}
