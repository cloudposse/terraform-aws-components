variable "region" {
  type        = string
  description = "AWS Region"
}

variable "allocated_storage" {
  type        = number
  description = "The amount of storage (in gigabytes) to be initially allocated for the replication instance. Default: 50, Min: 5, Max: 6144"
  default     = 50
}

variable "apply_immediately" {
  type        = bool
  description = "Indicates whether the changes should be applied immediately or during the next maintenance window. Only used when updating an existing resource"
  default     = true
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Indicates that major version upgrades are allowed"
  default     = true
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Indicates that major version upgrades are allowed"
  default     = false
}

variable "availability_zone" {
  type        = any
  description = "The EC2 Availability Zone that the replication instance will be created in"
  default     = null
}

variable "engine_version" {
  type        = string
  description = "The engine version number of the replication instance"
  default     = "3.4"
}

variable "multi_az" {
  type        = bool
  description = "Specifies if the replication instance is a multi-az deployment. You cannot set the `availability_zone` parameter if the `multi_az` parameter is set to true"
  default     = false
}

variable "preferred_maintenance_window" {
  type        = string
  description = "The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC)"
  default     = "sun:10:30-sun:14:30"
}

variable "publicly_accessible" {
  type        = bool
  description = "Specifies the accessibility options for the replication instance. A value of true represents an instance with a public IP address. A value of false represents an instance with a private IP address"
  default     = false
}

variable "replication_instance_class" {
  type        = string
  description = "The compute and memory capacity of the replication instance as specified by the replication instance class"
  default     = "dms.t2.small"
}

variable "security_group_create_before_destroy" {
  type        = bool
  description = <<-EOT
    Set `true` to enable terraform `create_before_destroy` behavior on the created security group.
    We only recommend setting this `false` if you are importing an existing security group
    that you do not want replaced and therefore need full control over its name.
    Note that changing this value will always cause the security group to be replaced.
    EOT
  default     = true
}

variable "security_group_allow_all_egress" {
  type        = bool
  default     = true
  description = <<-EOT
    A convenience that adds to the rules a rule that allows all egress.
    If this is false and no egress rules are specified via `rules` or `rule-matrix`, then no egress will be allowed.
    EOT
}

variable "security_group_ingress_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "A list of CIDR blocks for the the cluster Security Group to allow ingress to the cluster security group."
}

variable "security_group_ingress_from_port" {
  type        = number
  default     = 0
  description = "Start port on which the Glue connection accepts incoming connections."
}

variable "security_group_ingress_to_port" {
  type        = number
  default     = 65535
  description = "End port on which the Glue connection accepts incoming connections."
}
