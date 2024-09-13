variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy the cluster in"
  default     = []
}

variable "node_group_size" {
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
  description = "The desired, minimum, and maximum number of nodes in the cluster."
}

variable "cluster_context" {
  type = object({
    ami_release_version        = string
    ami_type                   = string
    az_abbreviation_type       = string
    cluster_autoscaler_enabled = bool
    cluster_name               = string
    create_before_destroy      = bool
    # Obsolete, replaced by block_device_map
    #  disk_encryption_enabled    = bool
    #  disk_size                  = number
    instance_types    = list(string)
    kubernetes_labels = map(string)
    kubernetes_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    node_userdata = object({
      before_cluster_joining_userdata = optional(string)
      bootstrap_extra_args            = optional(string)
      kubelet_extra_args              = optional(string)
      after_cluster_joining_userdata  = optional(string)
    })
    kubernetes_version    = string
    module_depends_on     = optional(any)
    resources_to_tag      = list(string)
    subnet_type_tag_key   = string
    aws_ssm_agent_enabled = bool
    vpc_id                = string

    # block_device_map copied from cloudposse/terraform-aws-eks-node-group
    # Really, nothing is optional, but easier to keep in sync via copy and paste
    block_device_map = map(object({
      no_device    = optional(bool, null)
      virtual_name = optional(string, null)
      ebs = optional(object({
        delete_on_termination = optional(bool, true)
        encrypted             = optional(bool, true)
        iops                  = optional(number, null)
        kms_key_id            = optional(string, null)
        snapshot_id           = optional(string, null)
        throughput            = optional(number, null)
        volume_size           = optional(number, 20)
        volume_type           = optional(string, "gp3")
      }))
    }))

  })
  description = "The common settings for all node groups."
}
