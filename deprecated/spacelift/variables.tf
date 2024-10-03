variable "region" {
  type        = string
  description = "AWS Region"
}

variable "runner_image" {
  type        = string
  description = "Full address & tag of the Spacelift runner image (e.g. on ECR)"
}

variable "worker_pool_name_id_map" {
  type        = map(any)
  description = "Map of worker pool names to worker pool IDs"
  default     = {}
}

variable "terraform_version" {
  type        = string
  description = "Default Terraform version for all stacks created by this project"
}

variable "autodeploy" {
  type        = bool
  description = "Default autodeploy value for all stacks created by this project"
}

variable "git_repository" {
  type        = string
  description = "The Git repository name"
}

variable "git_branch" {
  type        = string
  description = "The Git branch name"
  default     = "main"
}

variable "git_commit_sha" {
  type        = string
  description = "The commit SHA for which to trigger a run. Requires `var.spacelift_run_enabled` to be set to `true`"
  default     = null
}

variable "spacelift_run_enabled" {
  type        = bool
  description = "Enable/disable creation of the `spacelift_run` resource"
  default     = false
}

variable "spacelift_component_path" {
  type        = string
  description = "The Spacelift Component Path"
  default     = "components/terraform"
}

variable "terraform_version_map" {
  type        = map(string)
  description = "A map to determine which Terraform patch version to use for each minor version"
  default     = {}
}

variable "stack_config_path_template" {
  type        = string
  description = "Stack config path template"
  default     = "stacks/%s.yaml"
}

variable "policies_available" {
  type        = list(string)
  description = "List of available default policies to create in Spacelift (these policies will not be attached to Spacelift stacks by default, use `var.policies_enabled`)"
  default = [
    "git_push.proposed-run",
    "git_push.tracked-run",
    "plan.default",
    "trigger.dependencies",
    "trigger.retries"
  ]
}

variable "policies_enabled" {
  type        = list(string)
  description = "DEPRECATED: Use `policies_by_id_enabled` instead. List of default policies created by this stack to attach to all Spacelift stacks"
  default     = []
}

variable "policies_by_id_enabled" {
  type        = list(string)
  description = "List of existing policy IDs to attach to all Spacelift stacks. These policies must already exist in Spacelift"
  default     = []
}

variable "policies_by_name_enabled" {
  type        = list(string)
  description = "List of existing policy names to attach to all Spacelift stacks. These policies must exist at `modules/spacelift/rego-policies` OR `var.policies_by_name_path`."
  default     = []
}

variable "policies_by_name_path" {
  type        = string
  description = "Path to the catalog of external Rego policies. The Rego files must exist in the caller's code at the path. The module will create Spacelift policies from the external Rego definitions"
  default     = ""
}

variable "administrative_stack_drift_detection_enabled" {
  type        = bool
  description = "Flag to enable/disable administrative stack drift detection"
  default     = true
}

variable "administrative_stack_drift_detection_reconcile" {
  type        = bool
  description = "Flag to enable/disable administrative stack drift automatic reconciliation. If drift is detected and `reconcile` is turned on, Spacelift will create a tracked run to correct the drift"
  default     = true
}

variable "administrative_stack_drift_detection_schedule" {
  type        = list(string)
  description = "List of cron expressions to schedule drift detection for the administrative stack"
  default     = ["0 4 * * *"]
}

variable "drift_detection_enabled" {
  type        = bool
  description = "Flag to enable/disable drift detection on the infrastructure stacks"
  default     = true
}

variable "drift_detection_reconcile" {
  type        = bool
  description = "Flag to enable/disable infrastructure stacks drift automatic reconciliation. If drift is detected and `reconcile` is turned on, Spacelift will create a tracked run to correct the drift"
  default     = true
}

variable "drift_detection_schedule" {
  type        = list(string)
  description = "List of cron expressions to schedule drift detection for the infrastructure stacks"
  default     = ["0 4 * * *"]
}

variable "aws_role_enabled" {
  type        = bool
  description = "Flag to enable/disable Spacelift to use AWS STS to assume the supplied IAM role and put its temporary credentials in the runtime environment"
  default     = false
}

variable "aws_role_arn" {
  type        = string
  description = "ARN of the AWS IAM role to assume and put its temporary credentials in the runtime environment"
  default     = null
}

variable "aws_role_external_id" {
  type        = string
  description = "Custom external ID (works only for private workers). See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html for more details"
  default     = null
}

variable "aws_role_generate_credentials_in_worker" {
  type        = bool
  description = "Flag to enable/disable generating AWS credentials in the private worker after assuming the supplied IAM role"
  default     = false
}

variable "stack_destructor_enabled" {
  type        = bool
  description = "Flag to enable/disable the stack destructor to destroy the resources of a stack before deleting the stack itself"
  default     = false
}

variable "context_filters" {
  type        = map(list(string))
  description = "Context filters to create stacks for specific context information. Valid lists are `namespaces`, `environments`, `tenants`, `stages`."
  default     = {}
}

variable "tag_filters" {
  type        = map(string)
  description = "A map of tags that will filter stack creation by the matching `tags` set in a component `vars` configuration."
  default     = {}
}

variable "administrative_push_policy_enabled" {
  type        = bool
  description = "Flag to enable/disable the global administrative push policy"
  default     = true
}

variable "administrative_trigger_policy_enabled" {
  type        = bool
  description = "Flag to enable/disable the global administrative trigger policy"
  default     = true
}

variable "infracost_enabled" {
  type        = bool
  description = "Flag to enable/disable infracost. If this is enabled, it will add infracost label to each stack. See [spacelift infracost](https://docs.spacelift.io/vendors/terraform/infracost) docs for more details."
  default     = false
}

variable "external_execution" {
  type        = bool
  description = "Set this to true if you're calling this module from outside of a Spacelift stack (e.g. the `complete` example)"
  default     = false
}

variable "before_init" {
  type        = list(string)
  description = "List of before-init scripts"
  default     = []
}

variable "attachment_space_id" {
  type        = string
  description = "Specify the space ID for attachments (e.g. policies, contexts, etc.)"
  default     = "legacy"
}

variable "stacks_space_id" {
  type        = string
  description = "Override the space ID for all stacks (unless the stack config has `dedicated_space` set to true). Otherwise, it will default to the admin stack's space."
  default     = null
}

variable "spacelift_stack_dependency_enabled" {
  type        = bool
  description = "If enabled, the `spacelift_stack_dependency` Spacelift resource will be used to create dependencies between stacks instead of using the `depends-on` labels. The `depends-on` labels will be removed from the stacks and the trigger policies for dependencies will be detached"
  default     = false
}
