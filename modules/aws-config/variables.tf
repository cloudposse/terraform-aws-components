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

variable "conformance_packs" {
  description = <<-DOC
    List of conformance packs. Each conformance pack is a map with the following keys: name, conformance_pack, parameter_overrides.

    For example:
    conformance_packs = [
      {
        name                  = "Operational-Best-Practices-for-CIS-AWS-v1.4-Level1"
        conformance_pack      = "https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level1.yaml"
        parameter_overrides   = {
          "AccessKeysRotatedParamMaxAccessKeyAge" = "45"
        }
      },
      {
        name                  = "Operational-Best-Practices-for-CIS-AWS-v1.4-Level2"
        conformance_pack      = "https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level2.yaml"
        parameter_overrides   = {
          "IamPasswordPolicyParamMaxPasswordAge" = "45"
        }
      }
    ]

    Complete list of AWS Conformance Packs managed by AWSLabs can be found here:
    https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs
  DOC
  type = list(object({
    name                = string
    conformance_pack    = string
    parameter_overrides = map(string)
  }))
  default = []
}

variable "rules_paths" {
  description = <<-DOC
    Additional rules might be set by specifying path to the rule file.

    For example:
    rule_paths = [
      "https://raw.githubusercontent.com/cloudposse/terraform-aws-config/0.17.0/catalog/account.yaml",
      "https://raw.githubusercontent.com/cloudposse/terraform-aws-config/0.17.0/catalog/acm.yaml",
      "https://raw.githubusercontent.com/cloudposse/terraform-aws-config/0.17.0/catalog/alb.yaml"
      ...
    ]
  DOC
  type        = set(string)
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
