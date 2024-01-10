variable "region" {
  description = "AWS Region."
  type        = string
}

variable "ssm_region" {
  description = "AWS Region where SSM secrets are stored. Defaults to `var.region`."
  type        = string
  default     = null
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

######## Helm Chart configurations

variable "charts" {
  description = "Map of Helm charts to install. Keys are \"controller\" and \"runner_sets\"."
  type = map(object({
    chart_version     = string
    chart             = optional(string, null) # defaults according to the key to "gha-runner-scale-set-controller" or "gha-runner-scale-set"
    chart_description = optional(string, null) # visible in Helm history
    chart_repository  = optional(string, "oci://ghcr.io/actions/actions-runner-controller-charts")
    wait              = optional(bool, true)
    atomic            = optional(bool, true)
    cleanup_on_fail   = optional(bool, true)
    timeout           = optional(number, null)
  }))
  validation {
    condition     = length(keys(var.charts)) == 2 && contains(keys(var.charts), "controller") && contains(keys(var.charts), "runner_sets")
    error_message = "Must have exactly two charts: \"controller\" and \"runner_sets\"."
  }
}

######## ImagePullSecret settings

variable "image_pull_secret_enabled" {
  type        = bool
  description = "Whether to configure the controller and runners with an image pull secret."
  default     = false
}

variable "image_pull_kubernetes_secret_name" {
  type        = string
  description = "Name of the Kubernetes Secret that will be used as the imagePullSecret."
  default     = "gha-image-pull-secret"
  nullable    = false
}

variable "create_image_pull_kubernetes_secret" {
  type        = bool
  description = <<-EOT
    If `true` and `image_pull_secret_enabled` is `true`, this component will create the Kubernetes image pull secret resource,
    using the value in SSM at the path specified by `ssm_image_pull_secret_path`.
    WARNING: This will cause the secret to be stored in plaintext in the Terraform state.
    If `false`, this component will not create a secret and you must create it
    (with the name given by `var.github_kubernetes_secret_name`) in every
    namespace where you are deploying controllers or runners.
    EOT
  default     = true
  nullable    = false
}

variable "ssm_image_pull_secret_path" {
  type        = string
  description = "SSM path to the base64 encoded `dockercfg` image pull secret."
  default     = "/github-action-runners/image-pull-secrets"
  nullable    = false
}

######## Controller-specific settings

variable "controller" {
  type = object({
    image = optional(object({
      repository  = optional(string, null)
      tag         = optional(string, null) # Defaults to the chart appVersion
      pull_policy = optional(string, null)
    }), null)
    replicas             = optional(number, 1)
    kubernetes_namespace = string
    create_namespace     = optional(bool, true)
    chart_values         = optional(any, null)
    affinity             = optional(map(string), {})
    labels               = optional(map(string), {})
    node_selector        = optional(map(string), {})
    priority_class_name  = optional(string, "")
    resources = optional(object({
      limits = optional(object({
        cpu    = optional(string, null)
        memory = optional(string, null)
      }), null)
      requests = optional(object({
        cpu    = optional(string, null)
        memory = optional(string, null)
      }), null)
    }), null)
    tolerations = optional(list(object({
      key      = string
      operator = string
      value    = optional(string, null)
      effect   = string
    })), [])
    log_level       = optional(string, "info")
    log_format      = optional(string, "json")
    update_strategy = optional(string, "immediate")
  })
  description = "Configuration for the controller."
}


######## Runner-specific settings

variable "github_app_id" {
  type        = string
  description = "The ID of the GitHub App to use for the runner controller. Leave empty if using a GitHub PAT."
  default     = null
}

variable "github_app_installation_id" {
  type        = string
  description = "The \"Installation ID\" of the GitHub App to use for the runner controller. Leave empty if using a GitHub PAT."
  default     = null
}

variable "ssm_github_secret_path" {
  type        = string
  description = "The path in SSM to the GitHub app private key file contents or GitHub PAT token."
  default     = "/github-action-runners/github-auth-secret"
  nullable    = false
}

variable "create_github_kubernetes_secret" {
  type        = bool
  description = <<-EOT
    If `true`, this component will create the Kubernetes Secret that will be used to get
    the GitHub App private key or GitHub PAT token, based on the value retrieved
    from SSM at the `var.ssm_github_secret_path`. WARNING: This will cause
    the secret to be stored in plaintext in the Terraform state.
    If `false`, this component will not create a secret and you must create it
    (with the name given by `var.github_kubernetes_secret_name`) in every
    namespace where you are deploying runners (the controller does not need it).
    EOT
  default     = true
}

variable "github_kubernetes_secret_name" {
  type        = string
  description = "Name of the Kubernetes Secret that will be used to get the GitHub App private key or GitHub PAT token."
  default     = "gha-github-secret"
  nullable    = false
}


variable "runners" {
  description = <<-EOT
  Map of Runner Scale Set configurations, with the key being the name of the runner set.
  Please note that the name must be in kebab-case (no underscores).

  For example:

  ```hcl
  organization-runner = {
    # Specify the scope (organization or repository) and the target
    # of the runner via the `github_url` input.
    # ex: https://github.com/myorg/myrepo or https://github.com/myorg
    github_url = https://github.com/myorg
    group = "core-automation" # Optional. Assigns the runners to a runner group, for access control.
    min_replicas = 1
    max_replicas = 5
  }
  ```
  EOT

  type = map(object({
    # we allow a runner to be disabled because Atmos cannot delete an inherited map object
    enabled              = optional(bool, true)
    github_url           = string
    group                = optional(string, null)
    kubernetes_namespace = optional(string, null) # defaults to the controller's namespace
    create_namespace     = optional(bool, true)
    image                = optional(string, "ghcr.io/actions/actions-runner:latest") # repo and tag
    mode                 = optional(string, "dind")                                  # Optional. Can be "dind" or "kubernetes".
    pod_labels           = optional(map(string), {})
    pod_annotations      = optional(map(string), {})
    affinity             = optional(map(string), {})
    node_selector        = optional(map(string), {})
    tolerations = optional(list(object({
      key      = string
      operator = string
      value    = optional(string, null)
      effect   = string
      # tolerationSeconds is not supported, because Terraform requires all objects in a list to have the same keys,
      # but tolerationSeconds must be omitted to get the default behavior of "tolerate forever".
      # If really needed, could use a default value of 1,000,000,000 (one billion seconds = about 32 years).
    })), [])
    min_replicas = number
    max_replicas = number

    # ephemeral_pvc_storage and _class are ignored for "dind" mode but required for "kubernetes" mode
    ephemeral_pvc_storage       = optional(string, null) # ex: 10Gi
    ephemeral_pvc_storage_class = optional(string, null)

    kubernetes_mode_service_account_annotations = optional(map(string), {})

    resources = optional(object({
      limits = optional(object({
        cpu               = optional(string, null)
        memory            = optional(string, null)
        ephemeral-storage = optional(string, null)
      }), null)
      requests = optional(object({
        cpu               = optional(string, null)
        memory            = optional(string, null)
        ephemeral-storage = optional(string, null)
      }), null)
    }), null)
  }))
  default = {}
}
