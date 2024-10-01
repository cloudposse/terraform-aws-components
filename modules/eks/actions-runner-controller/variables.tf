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

variable "controller_replica_count" {
  type        = number
  description = "The number of replicas of the runner-controller to run."
  default     = 2
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

variable "docker_config_json_enabled" {
  type        = bool
  description = "Whether the Docker config JSON is enabled"
  default     = false
}

variable "ssm_docker_config_json_path" {
  type        = string
  description = "SSM path to the Docker config JSON"
  default     = null
}

variable "runners" {
  description = <<-EOT
  Map of Action Runner configurations, with the key being the name of the runner. Please note that the name must be in
  kebab-case.

  For example:

  ```hcl
  organization_runner = {
    type = "organization" # can be either 'organization' or 'repository'
    dind_enabled: true # A Docker daemon will be started in the runner Pod
    image: summerwind/actions-runner-dind # If dind_enabled=false, set this to 'summerwind/actions-runner'
    scope = "ACME"  # org name for Organization runners, repo name for Repository runners
    group = "core-automation" # Optional. Assigns the runners to a runner group, for access control.
    scale_down_delay_seconds = 300
    min_replicas = 1
    max_replicas = 5
    labels = [
      "Ubuntu",
      "core-automation",
    ]
  }
  ```
  EOT

  type = map(object({
    type                = string
    scope               = string
    group               = optional(string, null)
    image               = optional(string, "summerwind/actions-runner-dind")
    auto_update_enabled = optional(bool, true)
    dind_enabled        = optional(bool, true)
    node_selector       = optional(map(string), {})
    pod_annotations     = optional(map(string), {})

    # running_pod_annotations are only applied to the pods once they start running a job
    running_pod_annotations = optional(map(string), {})

    # affinity is too complex to model. Whatever you assigned affinity will be copied
    # to the runner Pod spec.
    affinity = optional(any)

    tolerations = optional(list(object({
      key      = string
      operator = string
      value    = optional(string, null)
      effect   = string
    })), [])
    scale_down_delay_seconds = optional(number, 300)
    min_replicas             = number
    max_replicas             = number
    # Scheduled overrides. See https://github.com/actions/actions-runner-controller/blob/master/docs/automatically-scaling-runners.md#scheduled-overrides
    # Order is important. The earlier entry is prioritized higher than later entries. So you usually define
    # one-time overrides at the top of your list, then yearly, monthly, weekly, and lastly daily overrides.
    scheduled_overrides = optional(list(object({
      start_time   = string # ISO 8601 format, eg,  "2021-06-01T00:00:00+09:00"
      end_time     = string # ISO 8601 format, eg,  "2021-06-01T00:00:00+09:00"
      min_replicas = optional(number)
      max_replicas = optional(number)
      recurrence_rule = optional(object({
        frequency  = string           # One of Daily, Weekly, Monthly, Yearly
        until_time = optional(string) # ISO 8601 format time after which the schedule will no longer apply
      }))
    })), [])
    busy_metrics = optional(object({
      scale_up_threshold    = string
      scale_down_threshold  = string
      scale_up_adjustment   = optional(string)
      scale_down_adjustment = optional(string)
      scale_up_factor       = optional(string)
      scale_down_factor     = optional(string)
    }))
    webhook_driven_scaling_enabled = optional(bool, true)
    # max_duration is the duration after which a job will be considered completed,
    # even if the webhook has not received a "job completed" event.
    # This is to ensure that if an event is missed, it does not leave the runner running forever.
    # Set it long enough to cover the longest job you expect to run and then some.
    # See https://github.com/actions/actions-runner-controller/blob/9afd93065fa8b1f87296f0dcdf0c2753a0548cb7/docs/automatically-scaling-runners.md?plain=1#L264-L268
    # Defaults to 1 hour programmatically (to be able to detect if both max_duration and webhook_startup_timeout are set).
    max_duration = optional(string)
    # The name `webhook_startup_timeout` was misleading and has been deprecated.
    # It has been renamed `max_duration`.
    webhook_startup_timeout = optional(string)
    # Adjust the time (in seconds) to wait for the Docker in Docker daemon to become responsive.
    wait_for_docker_seconds     = optional(string, "")
    pull_driven_scaling_enabled = optional(bool, false)
    labels                      = optional(list(string), [])
    # If not null, `docker_storage` specifies the size (as `go` string) of
    # an ephemeral (default storage class) Persistent Volume to allocate for the Docker daemon.
    # Takes precedence over `tmpfs_enabled` for the Docker daemon storage.
    docker_storage = optional(string, null)
    # storage is deprecated in favor of docker_storage, since it is only storage for the Docker daemon
    storage = optional(string, null)
    # If `pvc_enabled` is true, a Persistent Volume Claim will be created for the runner
    # and mounted at /home/runner/work/shared. This is useful for sharing data between runners.
    pvc_enabled = optional(bool, false)
    # If `tmpfs_enabled` is `true`, both the runner and the docker daemon will use a tmpfs volume,
    # meaning that all data will be stored in RAM rather than on disk, bypassing disk I/O limitations,
    # but what would have been disk usage is now additional memory usage. You must specify memory
    # requests and limits when using tmpfs or else the Pod will likely crash the Node.
    tmpfs_enabled = optional(bool)
    resources = optional(object({
      limits = optional(object({
        cpu    = optional(string, "1")
        memory = optional(string, "1Gi")
        # ephemeral-storage is the Kubernetes name, but `ephemeral_storage` is the gomplate name,
        # so allow either. If both are specified, `ephemeral-storage` takes precedence.
        ephemeral-storage = optional(string)
        ephemeral_storage = optional(string, "10Gi")
      }), {})
      requests = optional(object({
        cpu    = optional(string, "500m")
        memory = optional(string, "256Mi")
        # ephemeral-storage is the Kubernetes name, but `ephemeral_storage` is the gomplate name,
        # so allow either. If both are specified, `ephemeral-storage` takes precedence.
        ephemeral-storage = optional(string)
        ephemeral_storage = optional(string, "1Gi")
      }), {})
    }), {})
  }))
}

variable "webhook" {
  type = object({
    enabled           = bool
    hostname_template = string
    queue_limit       = optional(number, 1000)
  })
  description = <<-EOT
    Configuration for the GitHub Webhook Server.
    `hostname_template` is the `format()` string to use to generate the hostname via `format(var.hostname_template, var.tenant, var.stage, var.environment)`"
    Typically something like `"echo.%[3]v.%[2]v.example.com"`.
    `queue_limit` is the maximum number of webhook events that can be queued up for processing by the autoscaler.
    When the queue gets full, webhook events will be dropped (status 500).
  EOT
  default = {
    enabled           = false
    hostname_template = null
    queue_limit       = 1000
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

variable "context_tags_enabled" {
  type        = bool
  description = "Whether or not to include all context tags as labels for each runner"
  default     = false
}
