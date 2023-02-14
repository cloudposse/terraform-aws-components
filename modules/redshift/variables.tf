variable "region" {
  type        = string
  description = "AWS region"
}

variable "cluster_identifier" {
  type        = string
  default     = ""
  description = "The Redshift cluster identifier. Must be a lower case string. Will use generated from label ID if not supplied"
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
  default     = "ra3.xlplus"
  description = "The node type to be provisioned for the cluster. See https://aws.amazon.com/redshift/pricing/ and https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-clusters.html#working-with-clusters-overview"
}

variable "cluster_type" {
  type        = string
  default     = "single-node"
  description = "The cluster type to use. Either `single-node` or `multi-node`"
}

variable "number_of_nodes" {
  type        = number
  default     = 1
  description = "The number of compute nodes in the cluster. This parameter is required when the `cluster_type` parameter is specified as `multi-node`"
}

variable "engine_version" {
  type        = string
  default     = null
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

// AWS KMS alias used for encryption/decryption of SSM secure strings
variable "kms_alias_name_ssm" {
  type        = string
  default     = "alias/aws/ssm"
  description = "KMS alias name for SSM"
}

variable "ssm_path_prefix" {
  type        = string
  default     = "redshift"
  description = "SSM path prefix (without leading or trailing slash)"
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
  description = "A list of CIDR blocks for the the cluster Security Group to allow ingress to the cluster security group"
}
