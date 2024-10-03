variable "region" {
  type        = string
  description = "AWS Region"
}

variable "alb_configuration" {
  type        = map(any)
  default     = {}
  description = "Map of multiple ALB configurations."
}

variable "alb_ingress_cidr_blocks_http" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks allowed to access environment over HTTP"
}

variable "alb_ingress_cidr_blocks_https" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks allowed to access environment over HTTPS"
}

variable "route53_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a route53 record for the ALB"
}

variable "acm_certificate_domain" {
  type        = string
  default     = null
  description = "Domain to get the ACM cert to use on the ALB."
}

variable "acm_certificate_domain_suffix" {
  type        = string
  default     = null
  description = "Domain suffix to use with dns delegated HZ to get the ACM cert to use on the ALB"
}

variable "route53_record_name" {
  type        = string
  default     = "*"
  description = "The route53 record name"
}

variable "internal_enabled" {
  type        = bool
  default     = false
  description = "Whether to create an internal load balancer for services in this cluster"
}

variable "maintenance_page_path" {
  type        = string
  default     = "templates/503_example.html"
  description = "The path from this directory to the text/html page to use as the maintenance page. Must be within 1024 characters"
}

variable "container_insights_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to enable container insights"
}

variable "dns_delegated_stage_name" {
  type        = string
  default     = null
  description = "Use this stage name to read from the remote state to get the dns_delegated zone ID"
}

variable "dns_delegated_environment_name" {
  type        = string
  default     = "gbl"
  description = "Use this environment name to read from the remote state to get the dns_delegated zone ID"
}

variable "dns_delegated_component_name" {
  type        = string
  default     = "dns-delegated"
  description = "Use this component name to read from the remote state to get the dns_delegated zone ID"
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of Security Group IDs to be allowed to connect to the ECS cluster"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the ECS cluster"
}

variable "capacity_providers_fargate" {
  description = "Use FARGATE capacity provider"
  type        = bool
  default     = true
}

variable "capacity_providers_fargate_spot" {
  description = "Use FARGATE_SPOT capacity provider"
  type        = bool
  default     = false
}

variable "capacity_providers_ec2" {
  description = "EC2 autoscale groups capacity providers"
  type = map(object({
    instance_type                        = string
    max_size                             = number
    security_group_ids                   = optional(list(string), [])
    min_size                             = optional(number, 0)
    image_id                             = optional(string)
    instance_initiated_shutdown_behavior = optional(string, "terminate")
    key_name                             = optional(string, "")
    user_data                            = optional(string, "")
    enable_monitoring                    = optional(bool, true)
    instance_warmup_period               = optional(number, 300)
    maximum_scaling_step_size            = optional(number, 1)
    minimum_scaling_step_size            = optional(number, 1)
    target_capacity_utilization          = optional(number, 100)
    ebs_optimized                        = optional(bool, false)
    block_device_mappings = optional(list(object({
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
    })), [])
    instance_market_options = optional(object({
      market_type = string
      spot_options = object({
        block_duration_minutes         = number
        instance_interruption_behavior = string
        max_price                      = number
        spot_instance_type             = string
        valid_until                    = string
      })
    }))
    instance_refresh = optional(object({
      strategy = string
      preferences = optional(object({
        instance_warmup        = optional(number, null)
        min_healthy_percentage = optional(number, null)
        skip_matching          = optional(bool, null)
        auto_rollback          = optional(bool, null)
      }), null)
      triggers = optional(list(string), [])
    }))
    mixed_instances_policy = optional(object({
      instances_distribution = object({
        on_demand_allocation_strategy            = string
        on_demand_base_capacity                  = number
        on_demand_percentage_above_base_capacity = number
        spot_allocation_strategy                 = string
        spot_instance_pools                      = number
        spot_max_price                           = string
      })
      }), {
      instances_distribution = null
    })
    placement = optional(object({
      affinity          = string
      availability_zone = string
      group_name        = string
      host_id           = string
      tenancy           = string
    }))
    credit_specification = optional(object({
      cpu_credits = string
    }))
    elastic_gpu_specifications = optional(object({
      type = string
    }))
    disable_api_termination   = optional(bool, false)
    default_cooldown          = optional(number, 300)
    health_check_grace_period = optional(number, 300)
    force_delete              = optional(bool, false)
    termination_policies      = optional(list(string), ["Default"])
    suspended_processes       = optional(list(string), [])
    placement_group           = optional(string, "")
    metrics_granularity       = optional(string, "1Minute")
    enabled_metrics = optional(list(string), [
      "GroupMinSize",
      "GroupMaxSize",
      "GroupDesiredCapacity",
      "GroupInServiceInstances",
      "GroupPendingInstances",
      "GroupStandbyInstances",
      "GroupTerminatingInstances",
      "GroupTotalInstances",
      "GroupInServiceCapacity",
      "GroupPendingCapacity",
      "GroupStandbyCapacity",
      "GroupTerminatingCapacity",
      "GroupTotalCapacity",
      "WarmPoolDesiredCapacity",
      "WarmPoolWarmedCapacity",
      "WarmPoolPendingCapacity",
      "WarmPoolTerminatingCapacity",
      "WarmPoolTotalCapacity",
      "GroupAndWarmPoolDesiredCapacity",
      "GroupAndWarmPoolTotalCapacity",
    ])
    wait_for_capacity_timeout            = optional(string, "10m")
    service_linked_role_arn              = optional(string, "")
    metadata_http_endpoint_enabled       = optional(bool, true)
    metadata_http_put_response_hop_limit = optional(number, 2)
    metadata_http_tokens_required        = optional(bool, true)
    metadata_http_protocol_ipv6_enabled  = optional(bool, false)
    tag_specifications_resource_types    = optional(set(string), ["instance", "volume"])
    max_instance_lifetime                = optional(number, null)
    capacity_rebalance                   = optional(bool, false)
    warm_pool = optional(object({
      pool_state                  = string
      min_size                    = number
      max_group_prepared_capacity = number
    }))
  }))
  default = {}
  validation {
    condition     = !contains(["FARGATE", "FARGATE_SPOT"], keys(var.capacity_providers_ec2))
    error_message = "'FARGATE' and 'FARGATE_SPOT' name is reserved"
  }
}
