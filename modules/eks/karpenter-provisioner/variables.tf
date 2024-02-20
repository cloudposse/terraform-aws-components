variable "region" {
  type        = string
  description = "AWS Region"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "vpc_component_name" {
  type        = string
  description = "The name of the vpc component"
  default     = "vpc"
  nullable    = false
}

variable "node_pools" {
  type = map(object({
    node_class = string
    # Disruption section which describes the ways in which Karpenter can disrupt and replace Nodes
    disruption = optional(object({
      consolidation_policy = string # Describes which types of Nodes Karpenter should consider for consolidation. Values: WhenUnderutilized or WhenEmpty
      consolidate_after    = string # The amount of time Karpenter should wait after discovering a consolidation decision
      expire_after         = string # The amount of time a Node can live on the cluster before being removed
      # Budgets control the speed Karpenter can scale down nodes.
      budgets = optional(list(object({
        nodes    = string
        schedule = optional(string)
        duration = optional(string)
      })), [])
    }))
    # Set acceptable (In) and unacceptable (Out) Kubernetes and Karpenter values for node provisioning based on Well-Known Labels and cloud-specific settings. These can include instance types, zones, computer architecture, and capacity type (such as AWS spot or on-demand). See https://karpenter.sh/v0.18.0/provisioner/#specrequirements for more details
    requirements = list(object({
      key      = string
      operator = string
      values   = list(string)
    }))
    # Karpenter provisioner taints configuration. See https://aws.github.io/aws-eks-best-practices/karpenter/#create-provisioners-that-are-mutually-exclusive for more details
    taints = optional(list(object({
      key    = string
      effect = string
      value  = optional(string)
    })), [])
    startup_taints = optional(list(object({
      key    = string
      effect = string
      value  = optional(string)
    })), [])
    # Karpenter provisioner total CPU limit for all pods running on the EC2 instances launched by Karpenter
    total_cpu_limit = string
    # Karpenter provisioner total memory limit for all pods running on the EC2 instances launched by Karpenter
    total_memory_limit = string
  }))
}

variable "node_classes" {
  type = map(object({
    # The AMI used by Karpenter provisioner when provisioning nodes. Based on the value set for amiFamily, Karpenter will automatically query for the appropriate EKS optimized AMI via AWS Systems Manager (SSM)
    ami_family = string
    # Karpenter provisioner metadata options. See https://karpenter.sh/v0.18.0/aws/provisioning/#metadata-options for more details
    metadata_options = optional(object({
      http_endpoint               = optional(string, "enabled"),  # valid values: enabled, disabled
      http_protocol_ipv6          = optional(string, "disabled"), # valid values: enabled, disabled
      http_put_response_hop_limit = optional(number, 2),          # limit of 1 discouraged because it keeps Pods from reaching metadata service
      http_tokens                 = optional(string, "required")  # valid values: required, optional
    })),
    # Whether to place EC2 instances launched by Karpenter into VPC private subnets. Set it to `false` to use public subnets
    private_subnets_enabled = optional(bool, true)
    # Karpenter provisioner block device mappings. Controls the Elastic Block Storage volumes that Karpenter attaches to provisioned nodes. Karpenter uses default block device mappings for the AMI Family specified. For example, the Bottlerocket AMI Family defaults with two block device mappings. See https://karpenter.sh/v0.18.0/aws/provisioning/#block-device-mappings for more details
    block_device_mappings = optional(list(object({
      device_name = string
      ebs = optional(object({
        volume_size           = string
        volume_type           = string
        delete_on_termination = optional(bool, true)
        encrypted             = optional(bool, true)
        iops                  = optional(number)
        kms_key_id            = optional(string, "alias/aws/ebs")
        snapshot_id           = optional(string)
        throughput            = optional(number)
      }))
    })), [])
  }))
  description = "Karpenter provisioners config"
}
