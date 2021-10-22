variable "region" {
  type        = string
  description = "AWS Region"
}

variable "iam_primary_roles_environment_name" {
  type        = string
  description = "The name of the environment where global `iam_primary_roles` is provisioned"
  default     = "gbl"
}

variable "iam_primary_roles_stage_name" {
  type        = string
  description = "The name of the stage where `iam_primary_roles` is provisioned"
  default     = "identity"
}

#######################################
# actions-runner-controller
variable "controller_chart_namespace" {
  type        = string
  default     = "actions-runner-system"
  description = "Controller kubernetes namespace."
}

variable "controller_chart_namespace_create" {
  type        = bool
  default     = true
  description = "Controller kubernetes namespace created if not present"
}

variable "controller_chart_release_name" {
  type        = string
  default     = "actions-runner-controller"
  description = "Controller Helm chart release name."
}

variable "controller_chart_name" {
  type        = string
  default     = "actions-runner-controller"
  description = "Controller Helm chart name."
}

variable "controller_chart_repo" {
  type        = string
  default     = "https://actions-runner-controller.github.io/actions-runner-controller"
  description = "Controller Helm chart repository name."
}

variable "controller_chart_version" {
  type        = string
  default     = "0.12.8"
  description = "Controller Helm chart version."
}

variable "controller_chart_image" {
  type        = string
  default     = "summerwind/actions-runner-controller"
  description = "Image to use for controller"
}

variable "controller_chart_image_tag" {
  type        = string
  default     = "v0.19.0"
  description = "Tag to use for controller image"
}

variable "controller_chart_values" {
  type        = any
  description = "Additional values to yamlencode as `helm_release` values."
  default     = {}
}

#######################################
# actions-runner-runner
variable "runner_chart_image" {
  type        = string
  default     = "actions-runner"
  description = "Controller Helm chart name."
}

variable "runner_chart_values" {
  type        = any
  description = "Additional values to yamlencode as `helm_release` values."
  default     = {}
}

variable "runner_type" {
  description = "Default choice if not defined in runner_configurations"
  default     = "small"
}

# runner_types:
#   small:
#     resources:
#       limits:
#         cpu: "3"
#         memory: "12Gi"
#       requests:
#         cpu: "1"
#         memory: "1Gi"
variable "runner_types" {
  description = "Map to define resources limits and requests"

  type = map(object({
    resources = object({
      limits = object({
        cpu    = string,
        memory = string
      }),
      requests = object({
        cpu    = string,
        memory = string
      })
    })
  }))

  default = {
    small = {
      resources = {
        limits = {
          cpu    = "3"
          memory = "12Gi"
        }
        requests = {
          cpu    = "1"
          memory = "1Gi"
        }
      }
    }
  }
}

variable "autoscale_type" {
  description = "Default choice if not defined in autoscale_types"
  default     = "low_concurrency"
}

#   low_concurrency:
#     minReplicas: 1
#     maxReplicas: 8
#     metrics:
#       type: PercentageRunnersBusy
#       scaleUpThreshold: '0.75'
#       scaleDownThreshold: '0.3'
#       scaleUpAdjustment: 1
#       scaleDownAdjustment: 1
variable "autoscale_types" {
  description = "Map to define HRA CRD scaling configurations"

  type = map(object({
    minReplicas = number,
    maxReplicas = number
    metrics = object({
      type                = string,
      scaleUpThreshold    = number,
      scaleDownThreshold  = number,
      scaleUpAdjustment   = number,
      scaleDownAdjustment = number
    })
  }))

  default = {
    low_concurrency = {
      minReplicas = 1
      maxReplicas = 8
      metrics = {
        type                = "PercentageRunnersBusy"
        scaleUpThreshold    = 0.75
        scaleDownThreshold  = 0.3
        scaleUpAdjustment   = 1
        scaleDownAdjustment = 1
      }
    }
  }
}

variable "runner_configurations" {
  description = "List of maps to create runners from"

  type = list(map(string))

  # runner_configuration must have a key of `repo` or `org` as its target
  validation {
    condition     = alltrue([for r in var.runner_configurations : lookup(r, "repo", "") != "" || lookup(r, "org", "") != ""])
    error_message = "Variable runner_configurations must contain a target key of either `repo` or `org`."
  }

  # runner_configuration cannot have both `repo` and `org`, there can be only one
  validation {
    condition     = alltrue([for r in var.runner_configurations : lookup(r, "repo", "") != "" && lookup(r, "org", "") != "" ? false : true])
    error_message = "Variable runner_configurations can contain only one target key of either `repo` or `org` not both."
  }

  # runner_configuration may only conatain map keys "repo", "org", "runner_type", "autoscale_type"
  validation {
    condition     = alltrue([for r in var.runner_configurations : alltrue([for k in keys(r) : contains(["repo", "org", "runner_type", "autoscale_type"], k)])])
    error_message = "Unknown map key, must be one of repo, org, runner_type or autoscale_type."
  }

}

## eks_iam

variable "iam_role_enabled" {
  type        = bool
  description = "Whether to create an IAM role. Setting this to `true` will also replace any occurrences of `{service_account_role_arn}` in `var.values_template_path` with the ARN of the IAM role created by this module."
  default     = false
}

## eks_iam_policy

variable "iam_source_json_url" {
  type        = string
  description = "IAM source json policy to download. This will be used as the `source_json` meaning the `var.iam_policy_statements` and `var.iam_policy_statements_template_path` can override it."
  default     = null
}

variable "iam_policy_statements" {
  type        = any
  description = "IAM policy for the service account. Required if `var.iam_role_enabled` is `true`. This will not do variable replacements. Please see `var.iam_policy_statements_template_path`."
  default     = {}
}

## eks_iam_role

variable "service_account_name" {
  type        = string
  description = "Kubernetes ServiceAccount name. Required if `var.iam_role_enabled` is `true`."
  default     = null
}

variable "service_account_namespace" {
  type        = string
  description = "Kubernetes Namespace where service account is deployed. Required if `var.iam_role_enabled` is `true`."
  default     = null
}
