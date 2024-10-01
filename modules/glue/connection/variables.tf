variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_component_name" {
  type        = string
  description = "VPC component name"
}

variable "connection_name" {
  type        = string
  description = "Connection name. If not provided, the name will be generated from the context"
  default     = null
}

variable "connection_description" {
  type        = string
  description = "Connection description"
  default     = null
}

variable "catalog_id" {
  type        = string
  description = "The ID of the Data Catalog in which to create the connection. If none is supplied, the AWS account ID is used by default"
  default     = null
}

variable "connection_type" {
  type        = string
  description = "The type of the connection. Supported are: JDBC, MONGODB, KAFKA, and NETWORK. Defaults to JDBC"

  validation {
    condition     = contains(["JDBC", "MONGODB", "KAFKA", "NETWORK"], var.connection_type)
    error_message = "Supported are: JDBC, MONGODB, KAFKA, and NETWORK"
  }
}

variable "connection_properties" {
  type        = map(string)
  description = "A map of key-value pairs used as parameters for this connection"
  default     = null
}

variable "match_criteria" {
  type        = list(string)
  description = "A list of criteria that can be used in selecting this connection"
  default     = null
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

variable "security_group_ingress_from_port" {
  type        = number
  default     = 0
  description = "Start port on which the Glue connection accepts incoming connections"
}

variable "security_group_ingress_to_port" {
  type        = number
  default     = 0
  description = "End port on which the Glue connection accepts incoming connections"
}

variable "physical_connection_enabled" {
  type        = bool
  description = "Flag to enable/disable physical connection"
  default     = false
}

variable "connection_db_name" {
  type        = string
  description = "Database name that the Glue connector will reference"
  default     = null
}

variable "ssm_path_username" {
  type        = string
  description = "Database username SSM path"
  default     = null
}

variable "ssm_path_password" {
  type        = string
  description = "Database password SSM path"
  default     = null
}

variable "ssm_path_endpoint" {
  type        = string
  description = "Database endpoint SSM path"
  default     = null
}

variable "target_security_group_rules" {
  type        = list(any)
  description = "Additional Security Group rules that allow Glue to communicate with the target database"
  default     = []
}

variable "db_type" {
  type        = string
  description = "Database type for the connection URL: `postgres` or `redshift`"
  default     = "redshift"
}
