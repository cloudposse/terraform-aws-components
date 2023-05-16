variable "region" {
  type        = string
  description = "AWS Region"
}

variable "account_map_tenant" {
  type        = string
  default     = ""
  description = "(Optional) The tenant where the account_map component required by remote-state is deployed."
}

variable "root_account_stage" {
  type        = string
  default     = "root"
  description = "The stage name for the Organization root (master) account"
}

variable "global_environment" {
  type        = string
  default     = "gbl"
  description = "Global environment name"
}

variable "privileged" {
  type        = bool
  description = "True if the default provider already has access to the backend"
  default     = false
}

variable "config_bucket_stage" {
  type        = string
  description = "The stage of the AWS Config S3 Bucket"
}

variable "config_bucket_env" {
  type        = string
  description = "The environment of the AWS Config S3 Bucket"
}

variable "config_bucket_tenant" {
  type        = string
  default     = ""
  description = "(Optional) The tenant of the AWS Config S3 Bucket"
}

variable "cloudtrail_bucket_stage" {
  type        = string
  description = "The stage of the AWS Cloudtrail S3 Bucket"
}

variable "cloudtrail_bucket_env" {
  type        = string
  description = "The environment of the AWS Cloudtrail S3 Bucket"
}

variable "cloudtrail_bucket_tenant" {
  type        = string
  default     = ""
  description = "(Optional) The tenant of the AWS Cloudtrail S3 Bucket"
}

variable "global_resource_collector_region" {
  description = "The region that collects AWS Config data for global resources such as IAM"
  type        = string
}

variable "central_resource_collector_account" {
  description = <<-DOC
    The name of the account that is the centralized aggregation account.
  DOC
  type        = string
}

variable "create_iam_role" {
  description = "Flag to indicate whether an IAM Role should be created to grant the proper permissions for AWS Config"
  type        = bool
  default     = false
}

variable "az_abbreviation_type" {
  type        = string
  description = "Use fixed or short"
  default     = "fixed"
}

variable "iam_role_arn" {
  description = <<-DOC
    The ARN for an IAM Role AWS Config uses to make read or write requests to the delivery channel and to describe the 
    AWS resources associated with the account. This is only used if create_iam_role is false.
  
    If you want to use an existing IAM Role, set the value of this to the ARN of the existing topic and set 
    create_iam_role to false.
    
    See the AWS Docs for further information: 
    http://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
  DOC
  default     = null
  type        = string
}

variable "central_logging_account" {
  description = <<-DOC
    The name of the account that is the centralized logging account. The config rules associated with logging in the 
    catalog (loggingAccountOnly: true) will be installed only in this account.
  DOC
  type        = string
}

variable "support_role_arn" {
  type        = string
  description = "Used to manually define support role instead of remote-state lookup (used for identity account)."
  default     = ""
}

variable "config_rules_paths" {
  type        = set(string)
  description = "The paths to where config rules are located"
  default     = []
}

variable "delegated_accounts" {
  description = "The account IDs of other accounts that will send their AWS Configuration or Security Hub data to this account"
  type        = set(string)
  default     = null
}

variable "iam_roles_environment_name" {
  type        = string
  description = "The name of the environment where the IAM roles are provisioned"
  default     = "gbl"
}
