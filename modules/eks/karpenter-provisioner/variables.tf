variable "region" {
  type        = string
  description = "AWS Region"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "provisioners" {
  type = map(object({
    # The name of the Karpenter provisioner
    name = string
    # Whether to place EC2 instances launched by Karpenter into VPC private subnets. Set it to `false` to use public subnets
    private_subnets_enabled = optional(bool, true)
    # Configures Karpenter to terminate empty nodes after the specified number of seconds. This behavior can be disabled by setting the value to `null` (never scales down if not set)
    # Conflicts with `consolidation.enabled`, which is usually a better option.
    ttl_seconds_after_empty = optional(number, null)
    # Configures Karpenter to terminate nodes when a maximum age is reached. This behavior can be disabled by setting the value to `null` (never expires if not set)
    ttl_seconds_until_expired = optional(number, null)
    # Continuously binpack containers into least possible number of nodes. Mutually exclusive with ttl_seconds_after_empty.
    # Ideally `true` by default, but conflicts with `ttl_seconds_after_empty`, which was previously the only option.
    consolidation = optional(object({
      enabled = bool
    }), { enabled = false })
    # Karpenter provisioner total CPU limit for all pods running on the EC2 instances launched by Karpenter
    total_cpu_limit = string
    # Karpenter provisioner total memory limit for all pods running on the EC2 instances launched by Karpenter
    total_memory_limit = string
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
      value  = string
    })), [])
    startup_taints = optional(list(object({
      key    = string
      effect = string
      value  = string
    })), [])
    # Karpenter provisioner metadata options. See https://karpenter.sh/v0.18.0/aws/provisioning/#metadata-options for more details
    metadata_options = optional(object({
      httpEndpoint            = optional(string, "enabled"),  # valid values: enabled, disabled
      httpProtocolIPv6        = optional(string, "disabled"), # valid values: enabled, disabled
      httpPutResponseHopLimit = optional(number, 2),          # limit of 1 discouraged because it keeps Pods from reaching metadata service
      httpTokens              = optional(string, "required")  # valid values: required, optional
    })),
    # The AMI used by Karpenter provisioner when provisioning nodes. Based on the value set for amiFamily, Karpenter will automatically query for the appropriate EKS optimized AMI via AWS Systems Manager (SSM)
    ami_family = string
    # Karpenter provisioner block device mappings. Controls the Elastic Block Storage volumes that Karpenter attaches to provisioned nodes. Karpenter uses default block device mappings for the AMI Family specified. For example, the Bottlerocket AMI Family defaults with two block device mappings. See https://karpenter.sh/v0.18.0/aws/provisioning/#block-device-mappings for more details
    block_device_mappings = optional(list(object({
      deviceName = string
      ebs = optional(object({
        volumeSize          = string
        volumeType          = string
        deleteOnTermination = optional(bool, true)
        encrypted           = optional(bool, true)
        iops                = optional(number)
        kmsKeyID            = optional(string, "alias/aws/ebs")
        snapshotID          = optional(string)
        throughput          = optional(number)
      }))
    })), [])
  }))
  description = "Karpenter provisioners config"
}
