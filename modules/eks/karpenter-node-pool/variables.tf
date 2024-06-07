variable "region" {
  type        = string
  description = "AWS Region"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "node_pools" {
  type = map(object({
    # The name of the Karpenter provisioner. The map key is used if this is not set.
    name = optional(string)
    # Whether to place EC2 instances launched by Karpenter into VPC private subnets. Set it to `false` to use public subnets.
    private_subnets_enabled = bool
    # The Disruption spec controls how Karpenter scales down the node group.
    # See the example (sadly not the specific `spec.disruption` documentation) at https://karpenter.sh/docs/concepts/nodepools/ for details
    disruption = optional(object({
      # Describes which types of Nodes Karpenter should consider for consolidation.
      # If using 'WhenUnderutilized', Karpenter will consider all nodes for consolidation and attempt to remove or
      # replace Nodes when it discovers that the Node is underutilized and could be changed to reduce cost.
      # If using `WhenEmpty`, Karpenter will only consider nodes for consolidation that contain no workload pods.
      consolidation_policy = optional(string, "WhenUnderutilized")

      # The amount of time Karpenter should wait after discovering a consolidation decision (`go` duration string, s, m, or h).
      # This value can currently (v0.36.0) only be set when the consolidationPolicy is 'WhenEmpty'.
      # You can choose to disable consolidation entirely by setting the string value 'Never' here.
      # Earlier versions of Karpenter called this field `ttl_seconds_after_empty`.
      consolidate_after = optional(string)

      # The amount of time a Node can live on the cluster before being removed (`go` duration string, s, m, or h).
      # You can choose to disable expiration entirely by setting the string value 'Never' here.
      # This module sets a default of 336 hours (14 days), while the Karpenter default is 720 hours (30 days).
      # Note that Karpenter calls this field "expiresAfter", and earlier versions called it `ttl_seconds_until_expired`,
      # but we call it "max_instance_lifetime" to match the corresponding field in EC2 Auto Scaling Groups.
      max_instance_lifetime = optional(string, "336h")

      # Budgets control the the maximum number of NodeClaims owned by this NodePool that can be terminating at once.
      # See https://karpenter.sh/docs/concepts/disruption/#disruption-budgets for details.
      # A percentage is the percentage of the total number of active, ready nodes not being deleted, rounded up.
      # If there are multiple active budgets, Karpenter uses the most restrictive value.
      # If left undefined, this will default to one budget with a value of nodes: 10%.
      # Note that budgets do not prevent or limit involuntary terminations.
      # Example:
      #   On Weekdays during business hours, don't do any deprovisioning.
      #     budgets = {
      #       schedule = "0 9 * * mon-fri"
      #       duration = 8h
      #       nodes    = "0"
      #     }
      budgets = optional(list(object({
        # The schedule specifies when a budget begins being active, using extended cronjob syntax.
        # See https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#schedule-syntax for syntax details.
        # Timezones are not supported. This field is required if Duration is set.
        schedule = optional(string)
        # Duration determines how long a Budget is active after each Scheduled start.
        # If omitted, the budget is always active. This is required if Schedule is set.
        # Must be a whole number of minutes and hours, as cron does not work in seconds,
        # but since Go's `duration.String()` always adds a "0s" at the end, that is allowed.
        duration = optional(string)
        # The percentage or number of nodes that Karpenter can scale down during the budget.
        nodes = string
      })), [])
    }), {})
    # Karpenter provisioner total CPU limit for all pods running on the EC2 instances launched by Karpenter
    total_cpu_limit = string
    # Karpenter provisioner total memory limit for all pods running on the EC2 instances launched by Karpenter
    total_memory_limit = string
    # Set a weight for this node pool.
    # See https://karpenter.sh/docs/concepts/scheduling/#weighted-nodepools
    weight      = optional(number, 50)
    labels      = optional(map(string))
    annotations = optional(map(string))
    # Karpenter provisioner taints configuration. See https://aws.github.io/aws-eks-best-practices/karpenter/#create-provisioners-that-are-mutually-exclusive for more details
    taints = optional(list(object({
      key    = string
      effect = string
      value  = string
    })))
    startup_taints = optional(list(object({
      key    = string
      effect = string
      value  = string
    })))
    # Karpenter node metadata options. See https://karpenter.sh/docs/concepts/nodeclasses/#specmetadataoptions for more details
    metadata_options = optional(object({
      httpEndpoint            = optional(string, "enabled")
      httpProtocolIPv6        = optional(string, "disabled")
      httpPutResponseHopLimit = optional(number, 2)
      # httpTokens can be either "required" or "optional"
      httpTokens = optional(string, "required")
    }), {})
    # The AMI used by Karpenter provisioner when provisioning nodes. Based on the value set for amiFamily, Karpenter will automatically query for the appropriate EKS optimized AMI via AWS Systems Manager (SSM)
    ami_family = string
    # Karpenter nodes block device mappings. Controls the Elastic Block Storage volumes that Karpenter attaches to provisioned nodes.
    # Karpenter uses default block device mappings for the AMI Family specified.
    # For example, the Bottlerocket AMI Family defaults with two block device mappings,
    # and normally you only want to scale `/dev/xvdb` where Containers and there storage are stored.
    # Most other AMIs only have one device mapping at `/dev/xvda`.
    # See https://karpenter.sh/docs/concepts/nodeclasses/#specblockdevicemappings for more details
    block_device_mappings = list(object({
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
    }))
    # Set acceptable (In) and unacceptable (Out) Kubernetes and Karpenter values for node provisioning based on Well-Known Labels and cloud-specific settings. These can include instance types, zones, computer architecture, and capacity type (such as AWS spot or on-demand). See https://karpenter.sh/v0.18.0/provisioner/#specrequirements for more details
    requirements = list(object({
      key      = string
      operator = string
      # Operators like "Exists" and "DoesNotExist" do not require a value
      values = optional(list(string))
    }))
  }))
  description = "Configuration for node pools. See code for details."
  nullable    = false
}
