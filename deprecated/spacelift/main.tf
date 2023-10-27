module "spacelift" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift"
  version = "0.55.0"

  context_filters = var.context_filters
  tag_filters     = var.tag_filters

  stack_config_path_template = var.stack_config_path_template
  components_path            = var.spacelift_component_path

  stacks_space_id     = var.stacks_space_id
  attachment_space_id = var.attachment_space_id

  branch                  = var.git_branch
  repository              = var.git_repository
  commit_sha              = var.git_commit_sha
  spacelift_run_enabled   = var.spacelift_run_enabled
  runner_image            = var.runner_image
  worker_pool_name_id_map = var.worker_pool_name_id_map
  autodeploy              = var.autodeploy
  manage_state            = false

  terraform_version     = var.terraform_version
  terraform_version_map = var.terraform_version_map

  imports_processing_enabled         = false
  stack_deps_processing_enabled      = false
  component_deps_processing_enabled  = true
  spacelift_stack_dependency_enabled = var.spacelift_stack_dependency_enabled

  policies_available       = var.policies_available
  policies_enabled         = var.policies_enabled
  policies_by_id_enabled   = var.policies_by_id_enabled
  policies_by_name_enabled = var.policies_by_name_enabled
  policies_by_name_path    = var.policies_by_name_path != "" ? var.policies_by_name_path : format("%s/rego-policies", path.module)

  administrative_push_policy_enabled    = var.administrative_push_policy_enabled
  administrative_trigger_policy_enabled = var.administrative_trigger_policy_enabled

  administrative_stack_drift_detection_enabled   = var.administrative_stack_drift_detection_enabled
  administrative_stack_drift_detection_reconcile = var.administrative_stack_drift_detection_reconcile
  administrative_stack_drift_detection_schedule  = var.administrative_stack_drift_detection_schedule

  drift_detection_enabled   = var.drift_detection_enabled
  drift_detection_reconcile = var.drift_detection_reconcile
  drift_detection_schedule  = var.drift_detection_schedule

  aws_role_enabled                        = var.aws_role_enabled
  aws_role_arn                            = var.aws_role_arn
  aws_role_external_id                    = var.aws_role_external_id
  aws_role_generate_credentials_in_worker = var.aws_role_generate_credentials_in_worker

  stack_destructor_enabled = var.stack_destructor_enabled
  infracost_enabled        = var.infracost_enabled
  external_execution       = var.external_execution

  before_init = var.before_init

  context = module.this.context
}
