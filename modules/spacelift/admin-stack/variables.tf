variable "admin_stack_label" {
  description = "Label to use to identify the admin stack when creating the child stacks"
  type        = string
  default     = "admin-stack-name"
}

variable "administrative" {
  type        = bool
  description = "Whether this stack can manage other stacks"
  default     = false
}

variable "allow_public_workers" {
  type        = bool
  description = "Whether to allow public workers to be used for this stack"
  default     = false
}
variable "autodeploy" {
  type        = bool
  description = "Controls the Spacelift 'autodeploy' option for a stack"
  default     = false
}

variable "autoretry" {
  type        = bool
  description = "Controls the Spacelift 'autoretry' option for a stack"
  default     = false
}

variable "aws_role_arn" {
  type        = string
  description = "ARN of the AWS IAM role to assume and put its temporary credentials in the runtime environment"
  default     = null
}

variable "aws_role_enabled" {
  type        = bool
  description = "Flag to enable/disable Spacelift to use AWS STS to assume the supplied IAM role and put its temporary credentials in the runtime environment"
  default     = false
}

variable "aws_role_external_id" {
  type        = string
  description = "Custom external ID (works only for private workers). See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html for more details"
  default     = null
}

variable "aws_role_generate_credentials_in_worker" {
  type        = bool
  description = "Flag to enable/disable generating AWS credentials in the private worker after assuming the supplied IAM role"
  default     = true
}

variable "azure_devops" {
  type        = map(any)
  description = "Azure DevOps VCS settings"
  default     = null
}

variable "bitbucket_cloud" {
  type        = map(any)
  description = "Bitbucket Cloud VCS settings"
  default     = null
}

variable "bitbucket_datacenter" {
  type        = map(any)
  description = "Bitbucket Datacenter VCS settings"
  default     = null
}

variable "branch" {
  type        = string
  description = "Specify which branch to use within your infrastructure repo"
  default     = "main"
}

variable "child_policy_attachments" {
  description = "List of policy attachments to attach to the child stacks created by this module"
  type        = set(string)
  default     = []
}

variable "cloudformation" {
  type        = map(any)
  description = "CloudFormation-specific configuration. Presence means this Stack is a CloudFormation Stack."
  default     = null
}

variable "commit_sha" {
  type        = string
  description = "The commit SHA for which to trigger a run. Requires `var.spacelift_run_enabled` to be set to `true`"
  default     = null
}

variable "component_env" {
  type        = any
  default     = {}
  description = "Map of component ENV variables"
}

variable "component_root" {
  type        = string
  description = "The path, relative to the root of the repository, where the component can be found"
}

variable "component_vars" {
  type        = any
  default     = {}
  description = "All Terraform values to be applied to the stack via a mounted file"
}

variable "context_attachments" {
  type        = set(string)
  description = "A list of context IDs to attach to this stack"
  default     = []
}

variable "context_filters" {
  description = "Context filters to select atmos stacks matching specific criteria to create as children."
  type = object({
    namespaces          = optional(list(string), [])
    environments        = optional(list(string), [])
    tenants             = optional(list(string), [])
    stages              = optional(list(string), [])
    tags                = optional(map(string), {})
    administrative      = optional(bool)
    root_administrative = optional(bool)
  })
}

variable "description" {
  type        = string
  description = "Specify description of stack"
  default     = null
}

variable "drift_detection_enabled" {
  type        = bool
  description = "Flag to enable/disable drift detection on the infrastructure stacks"
  default     = false
}

variable "drift_detection_reconcile" {
  type        = bool
  description = "Flag to enable/disable infrastructure stacks drift automatic reconciliation. If drift is detected and `reconcile` is turned on, Spacelift will create a tracked run to correct the drift"
  default     = false
}

variable "drift_detection_schedule" {
  type        = list(string)
  description = "List of cron expressions to schedule drift detection for the infrastructure stacks"
  default     = ["0 4 * * *"]
}

variable "drift_detection_timezone" {
  type        = string
  description = "Timezone in which the schedule is expressed. Defaults to UTC."
  default     = null
}

variable "github_enterprise" {
  type        = map(any)
  description = "GitHub Enterprise (self-hosted) VCS settings"
  default     = null
}

variable "gitlab" {
  type        = map(any)
  description = "GitLab VCS settings"
  default     = null
}

variable "labels" {
  type        = list(string)
  description = "A list of labels for the stack"
  default     = []
}

variable "local_preview_enabled" {
  type        = bool
  description = "Indicates whether local preview runs can be triggered on this Stack"
  default     = false
}

variable "manage_state" {
  type        = bool
  description = "Flag to enable/disable manage_state setting in stack"
  default     = false
}

variable "parent_space_id" {
  type        = string
  description = "If creating a dedicated space for this stack, specify the ID of the parent space in Spacelift."
  default     = null
}

variable "policy_ids" {
  type        = set(string)
  default     = []
  description = "Set of Rego policy IDs to attach to this stack"
}

variable "protect_from_deletion" {
  type        = bool
  description = "Flag to enable/disable deletion protection."
  default     = false
}

variable "pulumi" {
  type        = map(any)
  description = "Pulumi-specific configuration. Presence means this Stack is a Pulumi Stack."
  default     = null
}

variable "region" {
  type        = string
  description = "The AWS region to use"
  default     = "us-east-1"
}

variable "repository" {
  type        = string
  description = "The name of your infrastructure repo"
}

variable "root_admin_stack" {
  description = "Flag to indicate if this stack is the root admin stack. In this case, the stack will be created in the root space and will create all the other admin stacks as children."
  type        = bool
  default     = false
}

variable "root_stack_policy_attachments" {
  description = "List of policy attachments to attach to the root admin stack"
  type        = set(string)
  default     = []
}

variable "runner_image" {
  type        = string
  description = "The full image name and tag of the Docker image to use in Spacelift"
  default     = null
}

variable "showcase" {
  type        = map(any)
  description = "Showcase settings"
  default     = null
}

variable "space_id" {
  type        = string
  description = "Place the stack in the specified space_id."
  default     = "root"
}

variable "spacelift_run_enabled" {
  type        = bool
  description = "Enable/disable creation of the `spacelift_run` resource"
  default     = false
}

variable "spacelift_spaces_environment_name" {
  type        = string
  description = "The environment name of the spacelift spaces component"
  default     = null
}

variable "spacelift_spaces_stage_name" {
  type        = string
  description = "The stage name of the spacelift spaces component"
  default     = null
}

variable "spacelift_spaces_tenant_name" {
  type        = string
  description = "The tenant name of the spacelift spaces component"
  default     = null
}

variable "spacelift_spaces_component_name" {
  type        = string
  description = "The component name of the spacelift spaces component"
  default     = "spacelift/spaces"
}

variable "spacelift_stack_dependency_enabled" {
  type        = bool
  description = "If enabled, the `spacelift_stack_dependency` Spacelift resource will be used to create dependencies between stacks instead of using the `depends-on` labels. The `depends-on` labels will be removed from the stacks and the trigger policies for dependencies will be detached"
  default     = false
}

variable "stack_destructor_enabled" {
  type        = bool
  description = "Flag to enable/disable the stack destructor to destroy the resources of the stack before deleting the stack itself"
  default     = false
}

variable "stack_name" {
  type        = string
  description = "The name of the Spacelift stack"
  default     = null
}

variable "terraform_smart_sanitization" {
  type        = bool
  description = "Whether or not to enable [Smart Sanitization](https://docs.spacelift.io/vendors/terraform/resource-sanitization) which will only sanitize values marked as sensitive."
  default     = false
}

variable "terraform_version" {
  type        = string
  description = "Specify the version of Terraform to use for the stack"
  default     = null
}

variable "terraform_version_map" {
  type        = map(string)
  description = "A map to determine which Terraform patch version to use for each minor version"
  default     = {}
}

variable "terraform_workspace" {
  type        = string
  description = "Specify the Terraform workspace to use for the stack"
  default     = null
}

variable "webhook_enabled" {
  type        = bool
  description = "Flag to enable/disable the webhook endpoint to which Spacelift sends the POST requests about run state changes"
  default     = false
}

variable "webhook_endpoint" {
  type        = string
  description = "Webhook endpoint to which Spacelift sends the POST requests about run state changes"
  default     = null
}

variable "webhook_secret" {
  type        = string
  description = "Webhook secret used to sign each POST request so you're able to verify that the requests come from Spacelift"
  default     = null
}

variable "worker_pool_name" {
  type        = string
  description = "The atmos stack name of the worker pool. Example: `acme-core-ue2-auto-spacelift-default-worker-pool`"
  default     = null
}
