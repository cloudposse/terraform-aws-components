variable "region" {
  type        = string
  description = "AWS Region"
}

variable "mixed_instances_policy" {
  description = "Policy to use a mixed group of on-demand/spot of different types. Launch template is automatically generated. https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1"

  type = object({
    instances_distribution = object({
      on_demand_allocation_strategy            = string
      on_demand_base_capacity                  = number
      on_demand_percentage_above_base_capacity = number
      spot_allocation_strategy                 = string
      spot_instance_pools                      = number
      spot_max_price                           = string
    })
    override = list(object({
      instance_type     = string
      weighted_capacity = number
    }))
  })
  default = null
}

variable "ebs_optimized" {
  type        = bool
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "max_size" {
  type        = number
  description = "The maximum size of the autoscale group"
}

variable "min_size" {
  type        = number
  description = "The minimum size of the autoscale group"
}

variable "desired_capacity" {
  type        = number
  description = "The number of Amazon EC2 instances that should be running in the group, if not set will use `min_size` as value"
  default     = null
}

variable "wait_for_capacity_timeout" {
  type        = string
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior"
}

variable "cpu_utilization_high_threshold_percent" {
  type        = number
  description = "CPU utilization high threshold"
}

variable "cpu_utilization_low_threshold_percent" {
  type        = number
  description = "CPU utilization low threshold"
}

variable "default_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  default     = 300
}

variable "scale_down_cooldown_seconds" {
  type        = number
  default     = 300
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start"
}

variable "health_check_type" {
  type        = string
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`"
  default     = "EC2"
}

variable "health_check_grace_period" {
  type        = number
  description = "Time (in seconds) after instance comes into service before checking health"
  default     = 300
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default`"
  type        = list(string)
  default     = ["OldestLaunchConfiguration"]
}

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"

  type = list(object({
    device_name  = string
    no_device    = bool
    virtual_name = string
    ebs = object({
      delete_on_termination = bool
      encrypted             = bool
      iops                  = number
      kms_key_id            = string
      snapshot_id           = string
      volume_size           = number
      volume_type           = string
    })
  }))

  default = []
}

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


variable "ecr_region" {
  type        = string
  description = "AWS region that contains the ECR infrastructure repo"
  default     = ""
}

variable "ecr_repo_name" {
  type        = string
  description = "ECR repository name"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to use for workers"
  default     = "r5n.large"
}

variable "spacelift_runner_image" {
  type        = string
  description = "URL of ECR image to use for Spacelift"
  default     = ""
}

variable "spacelift_api_endpoint" {
  type        = string
  description = "The Spacelift API endpoint URL (e.g. https://example.app.spacelift.io)"
}

variable "spacelift_ami_id" {
  type        = string
  description = "AMI ID of Spacelift worker pool image"
  default     = null
}

variable "custom_spacelift_ami" {
  type        = bool
  description = "Custom spacelift AMI"
  default     = false
}

variable "spacelift_domain_name" {
  type        = string
  description = "Top-level domain name to use for pulling the launcher binary"
  default     = "spacelift.io"
}

variable "iam_attributes" {
  type        = list(string)
  description = "Additional attributes to add to the IDs of the IAM role and policy"
  default     = []
}

variable "instance_refresh" {
  description = "The instance refresh definition. If this block is configured, an Instance Refresh will be started when the Auto Scaling Group is updated"
  type = object({
    strategy = string
    preferences = object({
      instance_warmup        = number
      min_healthy_percentage = number
    })
    triggers = list(string)
  })

  default = null
}

variable "github_netrc_enabled" {
  type        = bool
  description = "Whether to create a GitHub .netrc file so Spacelift can clone private GitHub repositories."
  default     = false
}

variable "github_netrc_ssm_path_token" {
  type        = string
  description = "If `github_netrc` is enabled, this is the SSM path to retrieve the GitHub token."
  default     = "/github/token"
}

variable "github_netrc_ssm_path_user" {
  type        = string
  description = "If `github_netrc` is enabled, this is the SSM path to retrieve the GitHub user"
  default     = "/github/user"
}

variable "infracost_enabled" {
  type        = bool
  description = "Whether to enable infracost for Spacelift stacks"
  default     = false
}

variable "infracost_api_token_ssm_path" {
  type        = string
  description = "This is the SSM path to retrieve and set the INFRACOST_API_TOKEN environment variable"
  default     = "/infracost/token"
}

variable "infracost_cli_args" {
  type        = string
  description = "These are the CLI args passed to infracost"
  default     = ""
}

variable "infracost_warn_on_failure" {
  type        = bool
  description = "A failure executing Infracost, or a non-zero exit code being returned from the command will cause runs to fail. If this is true, this will only warn instead of failing the stack."
  default     = true
}

variable "aws_config_file" {
  type        = string
  description = "The AWS_CONFIG_FILE used by the worker. Can be overridden by `/.spacelift/config.yml`."
  default     = "/etc/aws-config/aws-config-spacelift"
}

variable "aws_profile" {
  type        = string
  description = <<-EOT
    The AWS_PROFILE used by the worker. If not specified, `"$${var.namespace}-identity"` will be used.
    Can be overridden by `/.spacelift/config.yml`.
    EOT
  default     = null
}

variable "spacelift_agents_per_node" {
  type        = number
  description = "Number of Spacelift agents to run on one worker node"
  default     = 1
}

variable "spacelift_aws_account_id" {
  type        = string
  description = "AWS Account ID owned by Spacelift"
  default     = "643313122712"
}
