variable "region" {
  type        = string
  description = "AWS Region"
}

variable "snowflake_account" {
  type        = string
  description = "The Snowflake account given with the AWS Marketplace Subscription."
}

variable "snowflake_account_region" {
  type        = string
  description = "AWS Region with the Snowflake subscription"
}

variable "ssm_path_snowflake_user_format" {
  type        = string
  default     = "/%s/%s/%s/%s/%s"
  description = "SSM parameter path format for a Snowflake user. For example, /snowflake/{{ account }}/users/{{ username }}/"
}

variable "snowflake_username_format" {
  type        = string
  default     = "%s-%s"
  description = "Snowflake username format"
}

variable "snowflake_admin_username" {
  type        = string
  default     = "admin"
  description = "Snowflake admin username created with the initial account subscription."
}

variable "default_warehouse_size" {
  type        = string
  default     = "xsmall"
  description = "The size for the default Snowflake Warehouse"
}

variable "terraform_user_first_name" {
  type        = string
  default     = "Terrafrom"
  description = "Snowflake Terraform first name given with User creation"
}

variable "terraform_user_last_name" {
  type        = string
  default     = "User"
  description = "Snowflake Terraform last name given with User creation"
}

variable "root_account_stage_name" {
  type        = string
  default     = "root"
  description = "The stage name for the AWS Organization root (master) account"
}

variable "global_environment_name" {
  type        = string
  default     = "gbl"
  description = "Global environment name"
}

variable "privileged" {
  type        = bool
  description = "True if the default provider already has access to the backend"
  default     = false
}

variable "service_user_id" {
  type        = string
  description = "The identifier for the service user created to manage infrastructure."
  default     = "terraform"
}

variable "snowflake_role_description" {
  type        = string
  description = "Comment to attach to the Snowflake Role."
  default     = "Terraform service user role."
}
