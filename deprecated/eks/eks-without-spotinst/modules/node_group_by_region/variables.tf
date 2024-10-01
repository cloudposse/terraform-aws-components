variable "availability_zones" {
  type = list(string)
}

variable "node_group_size" {
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
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
}
