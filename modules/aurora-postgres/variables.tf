variable "region" {
  type        = string
  description = "AWS Region"
}

variable "secondary_region_enabled" {
  type        = bool
  description = "Set true to create a read replica in a second region."
  default     = true
}

variable "cluster_name" {
  type        = string
  description = "Short name for this cluster"
}

variable "region_secondary" {
  type        = string
  description = "Secondary AWS Region"
}

variable "environment_secondary" {
  type        = string
  description = "Secondary region, e.g. 'uw2', 'uw1', 'en1', 'gbl'"
}

# AWS KMS alias used for encryption/decryption of SSM secure strings
variable "kms_alias_name_ssm" {
  default     = "alias/aws/ssm"
  description = "KMS alias name for SSM"
}

# Don't use `admin`
# Read more: <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
# ("MasterUsername admin cannot be used as it is a reserved word used by the engine")
variable "admin_user" {
  type        = string
  description = "Postgres admin user name"
  default     = ""

  validation {
    condition = (
      length(var.admin_user) == 0 ||
      (var.admin_user != "admin" &&
        length(var.admin_user) >= 1 &&
      length(var.admin_user) <= 16)
    )
    error_message = "Per the RDS API, admin cannot be used as it is a reserved word used by the engine. Master username must be between 1 and 16 characters. If null is provided then a random string will be used."
  }
}

# Must be longer than 8 chars
# Read more: <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
# ("The parameter MasterUserPassword is not a valid password because it is shorter than 8 characters")
variable "admin_password" {
  type        = string
  description = "Postgres password for the admin user"
  default     = ""

  # "sensitive" required Terraform 0.14 or later
  #  sensitive   = true

  validation {
    condition = (
      length(var.admin_password) == 0 ||
      (length(var.admin_password) >= 8 &&
      length(var.admin_password) <= 128)
    )
    error_message = "Per the RDS API, master password must be between 8 and 128 characters. If null is provided then a random password will be used."
  }
}

variable "dns_gbl_delegated_environment_name" {
  type        = string
  description = "The name of the environment where global `dns_delegated` is provisioned"
  default     = "gbl"
}

variable "primary_cluster_dns_name_part" {
  type        = string
  description = "Part of DNS name added to module and cluster name for DNS for primary cluster endpoint"
  default     = "primary-cluster"
}

variable "primary_reader_dns_name_part" {
  type        = string
  description = "Part of DNS name added to module and cluster name for DNS for primary cluster reader"
  default     = "primary-replicas"
}

variable "secondary_cluster_dns_name_part" {
  type        = string
  description = "Part of DNS name added to module and cluster name for DNS for secondary cluster endpoint"
  default     = "secondary-cluster"
}

variable "secondary_reader_dns_name_part" {
  type        = string
  description = "Part of DNS name added to module and cluster name for DNS for secondary reader endpoint"
  default     = "secondary-replicas"
}

variable "additional_databases" {
  type    = set(string)
  default = []
}

variable "additional_users" {
  type = map(object({
    db_user : string
    db_password : string
    grants : list(object({
      grant : list(string)
      db : string
      schema : string
      object_type : string
    }))
    superuser : bool
  }))
  default     = {}
  description = "Additional users to create. The map key is the service name which becomes part of SSM key name."
}

variable "ssm_path_prefix" {
  type        = string
  default     = "aurora-postgres"
  description = "SSM path prefix (without leading or trailing slash)"
}

variable "use_eks_security_group" {
  type        = bool
  description = "Use the eks default security group"
  default     = false
}
