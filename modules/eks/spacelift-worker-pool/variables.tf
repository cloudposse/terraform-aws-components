variable "region" {
  type        = string
  description = "AWS Region"
}

variable "spacelift_api_endpoint" {
  type        = string
  description = "The Spacelift API endpoint URL (e.g. https://example.app.spacelift.io)"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "space_name" {
  type        = string
  description = "The name of the Spacelift Space to create the worker pool in"
  default     = "root"
}

variable "worker_pool_description" {
  type        = string
  description = "Spacelift worker pool description. The default dynamically includes EKS cluster ID and Spacelift Space name."
  default     = null
}

variable "worker_pool_size" {
  type        = number
  description = "Worker pool size. The number of workers registered with Spacelift."
  default     = 1
}

variable "worker_spec" {
  type = object({
    tmpfs_enabled = optional(bool, false)
    resources = optional(object({
      limits = optional(object({
        cpu               = optional(string, "1")
        memory            = optional(string, "4500Mi")
        ephemeral-storage = optional(string, "2G")
      }), {})
      requests = optional(object({
        cpu               = optional(string, "750m")
        memory            = optional(string, "4Gi")
        ephemeral-storage = optional(string, "1G")
      }), {})
    }), {})
    annotations   = optional(map(string), {})
    node_selector = optional(map(string), {})
    tolerations = optional(list(object({
      key                = optional(string)
      operator           = optional(string)
      value              = optional(string)
      effect             = optional(string)
      toleration_seconds = optional(number)
    })), [])
    # activeDeadlineSeconds defines the length of time in seconds before which the Pod will
    # be marked as failed. This can be used to set a time limit for your runs.
    active_deadline_seconds          = optional(number, 4200) # 4200 seconds = 70 minutes
    termination_grace_period_seconds = optional(number, 50)
  })
  description = "Configuration for the Workers in the worker pool"
  default     = {}
}

variable "grpc_server_resources" {
  type = object({
    requests = optional(object({
      memory = optional(string, "50Mi")
      cpu    = optional(string, "50m")
    }), {})
    limits = optional(object({
      memory = optional(string, "500Mi")
      cpu    = optional(string, "500m")
    }), {})
  })
  description = "Resources for the gRPC server part of the worker pool deployment. The default values are usually sufficient."
  default     = {}
}

variable "keep_successful_pods" {
  type        = bool
  description = <<-EOT
      Indicates whether run Pods should automatically be removed as soon
      as they complete successfully, or be kept so that they can be inspected later. By default
      run Pods are removed as soon as they complete successfully. Failed Pods are not automatically
      removed to allow debugging.
    EOT
  default     = false
}

variable "iam_attributes" {
  type        = list(string)
  description = "Additional attributes to add to the IDs of the IAM role and policy"
  default     = []
}

variable "aws_config_file" {
  type        = string
  description = "The AWS_CONFIG_FILE used by the worker. Can be overridden by `/.spacelift/config.yml`."
}

variable "aws_profile" {
  type        = string
  description = <<-EOT
    The AWS_PROFILE used by the worker. If not specified, `"$${var.namespace}-identity"` will be used.
    Can be overridden by `/.spacelift/config.yml`.
    EOT
  default     = null
}

variable "ecr_environment_name" {
  type        = string
  description = "The name of the environment where `ecr` is provisioned"
  default     = ""
}

variable "ecr_stage_name" {
  type        = string
  description = "The name of the stage where `ecr` is provisioned"
  default     = "artifacts"
}

variable "ecr_tenant_name" {
  type        = string
  description = <<-EOT
  The name of the tenant where `ecr` is provisioned.

  If the `tenant` label is not used, leave this as `null`.
  EOT
  default     = null
}

variable "ecr_component_name" {
  type        = string
  description = "ECR component name"
  default     = "ecr"
}

variable "ecr_repo_name" {
  type        = string
  description = "ECR repository name"
}

variable "kubernetes_namespace" {
  type        = string
  description = "Name of the Kubernetes Namespace the Spacelift worker pool is deployed in to"
}

variable "kubernetes_service_account_name" {
  type        = string
  description = "Kubernetes service account name"
  default     = null
}

variable "kubernetes_service_account_enabled" {
  type        = bool
  description = "Flag to enable/disable Kubernetes service account"
  default     = false
  nullable    = false
}

variable "kubernetes_role_api_groups" {
  type        = list(string)
  description = "List of APIGroups for the Kubernetes Role created for the Kubernetes Service Account"
  default     = [""]
  nullable    = false
}

variable "kubernetes_role_resources" {
  type        = list(string)
  description = "List of resources for the Kubernetes Role created for the Kubernetes Service Account"
  default     = ["*"]
  nullable    = false
}

variable "kubernetes_role_resource_names" {
  type        = list(string)
  description = "List of resource names for the Kubernetes Role created for the Kubernetes Service Account"
  default     = null
}

variable "kubernetes_role_verbs" {
  type        = list(string)
  description = "List of verbs that apply to ALL the ResourceKinds for the Kubernetes Role created for the Kubernetes Service Account"
  default     = ["get", "list"]
  nullable    = false
}

variable "iam_permissions_boundary" {
  type        = string
  description = "ARN of the policy that is used to set the permissions boundary for the IAM Role"
  default     = null
}

variable "iam_source_json_url" {
  type        = string
  description = "IAM source JSON policy to download"
  default     = null
}

variable "iam_source_policy_documents" {
  type        = list(string)
  description = <<-EOT
    List of IAM policy documents that are merged together into the exported document.
    Statements defined in `iam_source_policy_documents` must have unique SIDs.
    Statements with the same SID as in statements in documents assigned to the
    `iam_override_policy_documents` arguments will be overridden.
    EOT
  default     = null
}

variable "iam_override_policy_documents" {
  type        = list(string)
  description = <<-EOT
    List of IAM policy documents that are merged together into the exported document with higher precedence.
    In merging, statements with non-blank SIDs will override statements with the same SID
    from earlier documents in the list and from other "source" documents.
    EOT
  default     = null
}
