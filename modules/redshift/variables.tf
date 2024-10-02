variable "region" {
  type        = string
  description = "AWS region"
}

variable "port" {
  type        = number
  default     = 5439
  description = "The port number on which the cluster accepts incoming connections"
}

variable "admin_user" {
  type        = string
  default     = null
  description = "Username for the master DB user. Required unless a snapshot_identifier is provided"
}

variable "admin_password" {
  type        = string
  default     = null
  description = "Password for the master DB user. Required unless a snapshot_identifier is provided"
}

variable "database_name" {
  type        = string
  default     = null
  description = "The name of the first database to be created when the cluster is created"
}

variable "node_type" {
  type        = string
  default     = "dc2.large"
  description = "The node type to be provisioned for the cluster. See https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-clusters.html#working-with-clusters-overview"
}

variable "number_of_nodes" {
  type        = number
  default     = 1
  description = "The number of compute nodes in the cluster. This parameter is required when the ClusterType parameter is specified as multi-node"
}

variable "cluster_type" {
  type        = string
  default     = "single-node"
  description = "The cluster type to use. Either `single-node` or `multi-node`"
}

variable "engine_version" {
  type        = string
  default     = "1.0"
  description = "The version of the Amazon Redshift engine to use. See https://docs.aws.amazon.com/redshift/latest/mgmt/cluster-versions.html"
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "If true, the cluster can be accessed from a public network"
}

variable "allow_version_upgrade" {
  type        = bool
  default     = false
  description = "Whether or not to enable major version upgrades which are applied during the maintenance window to the Amazon Redshift engine that is running on the cluster"
}

variable "use_private_subnets" {
  type        = bool
  default     = true
  description = "Whether to use private or public subnets for the Redshift cluster"
}

variable "security_group_ids" {
  type        = list(string)
  default     = null
  description = "An array of security group IDs to associate with the endpoint."
}

variable "custom_sg_enabled" {
  type        = bool
  default     = false
  description = "Whether to use custom security group or not"
}

variable "custom_sg_allow_all_egress" {
  type        = bool
  default     = true
  description = "Whether to allow all egress traffic or not"
}

variable "custom_sg_rules" {
  type = list(object({
    key         = string
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default     = []
  description = "An array of custom security groups to create and assign to the cluster."
}
