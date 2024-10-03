variable "region" {
  type        = string
  description = "AWS region"
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

variable "default_iam_role_arn" {
  type        = string
  default     = null
  description = "The Amazon Resource Name (ARN) of the IAM role to set as a default in the namespace"
}

variable "iam_roles" {
  type        = list(string)
  default     = []
  description = "A list of IAM roles to associate with the namespace."
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "The ARN of the Amazon Web Services Key Management Service key used to encrypt your data."
}

variable "log_exports" {
  type        = set(string)
  default     = []
  description = "The types of logs the namespace can export. Available export types are `userlog`, `connectionlog`, and `useractivitylog`."
}

variable "use_private_subnets" {
  type        = bool
  default     = true
  description = "Whether to use private or public subnets for the Redshift cluster"
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "If true, the cluster can be accessed from a public network"
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

variable "security_group_ids" {
  type        = list(string)
  default     = null
  description = "An array of security group IDs to associate with the endpoint."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = null
  description = "An array of security group IDs to associate with the workgroup."
}

variable "base_capacity" {
  type        = number
  default     = 128
  description = "The base data warehouse capacity of the workgroup in Redshift Processing Units (RPUs)."
}

variable "config_parameter" {
  type = list(object({
    parameter_key   = string
    parameter_value = any
  }))
  default     = []
  description = "A list of Redshift config parameters to apply to the workgroup."
}

variable "enhanced_vpc_routing" {
  type        = bool
  default     = true
  description = "The value that specifies whether to turn on enhanced virtual private cloud (VPC) routing, which forces Amazon Redshift Serverless to route traffic through your VPC instead of over the internet."
}

variable "endpoint_name" {
  type        = string
  default     = null
  description = "Endpoint name for the redshift endpoint, if null, is set to $stage-$name"
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
  description = "Custom security group rules"

}
