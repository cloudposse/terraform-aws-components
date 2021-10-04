variable "region" {
  type        = string
  description = "AWS Region"
}

variable "ami_filter" {
  description = "Map of lists used to look up the AMI which will be used for the GitHub Actions Runner."
  type        = map(list(string))

  default = {
    name = ["amzn2-ami-hvm-2.*-x86_64-ebs"]
  }
}

variable "ami_owners" {
  description = "The list of owners used to select the AMI of action runner instances."
  type        = list(string)
  default     = ["amazon"]
}

variable "instance_type" {
  description = "Default instance type for the action runner."
  type        = string
  default     = "m5.large"
}

variable "mixed_instances_policy" {
  description = "Policy to use a mixed group of on-demand/spot of differing types. Launch template is automatically generated. https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1"

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

variable "max_size" {
  type        = number
  description = "The maximum size of the autoscale group"
}

variable "min_size" {
  type        = number
  description = "The minimum size of the autoscale group"
}

variable "github_org" {
  description = "GitHub Org e.g. cloudposse"
  type        = string
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

variable "ssm_parameter_name_format" {
  type        = string
  default     = "/%s/%s"
  description = "SSM parameter name format"
}

variable "ssm_path" {
  type        = string
  default     = "github"
  description = "GitHub token SSM path"
}

variable "runner_version" {
  type        = string
  default     = "2.283.1"
  description = "GitHub runner release version"
}

variable "runner_labels" {
  type        = list(string)
  default     = []
  description = "List of labels to add to the GitHub Runner (e.g. 'Amazon Linux 2')."
}

variable "runner_role_additional_policy_arns" {
  type        = list(string)
  default     = []
  description = "List of policy ARNs that will be attached to the runners' default role on creation in addition to the defaults"
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