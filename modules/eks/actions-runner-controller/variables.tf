variable "region" {
  description = "AWS Region."
  type        = string
}

variable "chart_description" {
  type        = string
  description = "Set release description attribute (visible in the history)."
  default     = null
}

variable "chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended."
}

variable "chart_repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = null
}

variable "resources" {
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  description = "The cpu and memory of the deployment's limits and requests."
}

variable "create_namespace" {
  type        = bool
  description = "Create the namespace if it does not yet exist. Defaults to `false`."
  default     = null
}

variable "kubernetes_namespace" {
  type        = string
  description = "The namespace to install the release into."
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds"
  default     = null
}

variable "cleanup_on_fail" {
  type        = bool
  description = "Allow deletion of new resources created in this upgrade when upgrade fails."
  default     = true
}

variable "atomic" {
  type        = bool
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used."
  default     = true
}

variable "wait" {
  type        = bool
  description = "Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`."
  default     = null
}

variable "chart_values" {
  type        = any
  description = "Additional values to yamlencode as `helm_release` values."
  default     = {}
}

variable "rbac_enabled" {
  type        = bool
  default     = true
  description = "Service Account for pods."
}

# Runner-specific settings

/*
variable "account_map_environment_name" {
  type        = string
  description = "The name of the environment where `account_map` is provisioned"
  default     = "gbl"
}

variable "account_map_stage_name" {
  type        = string
  description = "The name of the stage where `account_map` is provisioned"
  default     = "root"
}

variable "account_map_tenant_name" {
  type        = string
  description = <<-EOT
  The name of the tenant where `account_map` is provisioned.

  If the `tenant` label is not used, leave this as `null`.
  EOT
  default     = "core"
}

*/

variable "existing_kubernetes_secret_name" {
  type        = string
  description = <<-EOT
    If you are going to create the Kubernetes Secret the runner-controller will use
    by some means (such as SOPS) outside of this component, set the name of the secret
    here and it will be used. In this case, this component will not create a secret
    and you can leave the secret-related inputs with their default (empty) values.
    The same secret will be used by both the runner-controller and the webhook-server.
    EOT
  default     = ""
}

variable "s3_bucket_arns" {
  type        = list(string)
  description = "List of ARNs of S3 Buckets to which the runners will have read-write access to."
  default     = []
}

variable "runners" {
  description = <<-EOT
  Map of Action Runner configurations, with the key being the name of the runner. Please note that the name must be in
  kebab-case.

  For example:

  ```hcl
  organization_runner = {
    type = "organization" # can be either 'organization' or 'repository'
    dind_enabled: false # A Docker sidecar container will be deployed
    image: summerwind/actions-runner # If dind_enabled=true, set this to 'summerwind/actions-runner-dind'
    scope = "ACME"  # org name for Organization runners, repo name for Repository runners
    scale_down_delay_seconds = 300
    min_replicas = 1
    max_replicas = 5
    busy_metrics = {
      scale_up_threshold = 0.75
      scale_down_threshold = 0.25
      scale_up_factor = 2
      scale_down_factor = 0.5
    }
    labels = [
      "Ubuntu",
      "core-automation",
    ]
  }
  ```
  EOT

  type = map(object({
    type                     = string
    scope                    = string
    image                    = optional(string, "")
    dind_enabled             = bool
    scale_down_delay_seconds = number
    min_replicas             = number
    max_replicas             = number
    busy_metrics = optional(object({
      scale_up_threshold    = string
      scale_down_threshold  = string
      scale_up_adjustment   = optional(string)
      scale_down_adjustment = optional(string)
      scale_up_factor       = optional(string)
      scale_down_factor     = optional(string)
    }))
    webhook_driven_scaling_enabled = bool
    webhook_startup_timeout        = optional(string, null)
    pull_driven_scaling_enabled    = bool
    labels                         = list(string)
    storage                        = optional(string, false)
    pvc_enabled                    = optional(string, false)
    resources = object({
      limits = object({
        cpu               = string
        memory            = string
        ephemeral_storage = optional(string, false)
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
  }))
}

variable "webhook" {
  type = object({
    enabled           = bool
    hostname_template = string
  })
  description = <<-EOT
    Configuration for the GitHub Webhook Server.
    `hostname_template` is the `format()` string to use to generate the hostname via `format(var.hostname_template, var.tenant, var.stage, var.environment)`"
    Typically something like `"echo.%[3]v.%[2]v.example.com"`.
  EOT
  default = {
    enabled           = false
    hostname_template = null
  }
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "github_app_id" {
  type        = string
  description = "The ID of the GitHub App to use for the runner controller."
  default     = ""
}

variable "github_app_installation_id" {
  type        = string
  description = "The \"Installation ID\" of the GitHub App to use for the runner controller."
  default     = ""
}

variable "ssm_github_secret_path" {
  type        = string
  description = "The path in SSM to the GitHub app private key file contents or GitHub PAT token."
  default     = ""
}

variable "ssm_github_webhook_secret_token_path" {
  type        = string
  description = "The path in SSM to the GitHub Webhook Secret token."
  default     = ""
}
