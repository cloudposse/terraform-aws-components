variable "availability_zone" {
  type        = string
  description = "The availability zone to deploy the node group in"
}

variable "node_group_size" {
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
  description = "The desired, minimum and maximum size of the node group in this availability zone"
}

variable "cluster_context" {
  type = object({
    ami_release_version        = string
    ami_type                   = string
    az_abbreviation_type       = string
    cluster_autoscaler_enabled = bool
    cluster_name               = string
    create_before_destroy      = bool
    disk_encryption_enabled    = bool
    disk_size                  = number
    instance_types             = list(string)
    kubernetes_labels          = map(string)
    kubernetes_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    kubernetes_version    = string
    module_depends_on     = any
    resources_to_tag      = list(string)
    subnet_type_tag_key   = string
    aws_ssm_agent_enabled = bool
    vpc_id                = string
  })
  description = "The common settings for all node groups."
}

variable "block_device_name" {
  type        = string
  default     = "/dev/xvda"
  description = "The name of the device to mount"
}

variable "block_device_volume_type" {
  type        = string
  default     = "gp2"
  description = "The volume type. Can be one of standard, gp2, gp3, io1, io2, sc1 or st1"
}
