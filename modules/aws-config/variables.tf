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

variable "global_resource_collector_region" {
  description = "The region that collects AWS Config data for global resources such as IAM"
  type        = string
}

variable "central_resource_collector_account" {
  description = "The name of the account that is the centralized aggregation account."
  type        = string
}

variable "create_iam_role" {
  description = "Flag to indicate whether an IAM Role should be created to grant the proper permissions for AWS Config"
  type        = bool
  default     = false
}

variable "az_abbreviation_type" {
  type        = string
  description = "AZ abbreviation type, `fixed` or `short`"
  default     = "fixed"
}

variable "iam_role_arn" {
  description = <<-DOC
    The ARN for an IAM Role AWS Config uses to make read or write requests to the delivery channel and to describe the
    AWS resources associated with the account. This is only used if create_iam_role is false.

    If you want to use an existing IAM Role, set the variable to the ARN of the existing role and set create_iam_role to `false`.

    See the AWS Docs for further information:
    http://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
  DOC
  default     = null
  type        = string
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
    scope               = optional(string, null)
  }))
  default = []
  validation {
    # verify scope is valid
    condition     = alltrue([for conformance_pack in var.conformance_packs : conformance_pack.scope == null || conformance_pack.scope == "account" || conformance_pack.scope == "organization"])
    error_message = "The scope must be either `account` or `organization`."
  }
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

variable "managed_rules" {
  description = <<-DOC
    A list of AWS Managed Rules that should be enabled on the account.

    See the following for a list of possible rules to enable:
    https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html

    Example:
    ```
    managed_rules = {
      access-keys-rotated = {
        identifier  = "ACCESS_KEYS_ROTATED"
        description = "Checks whether the active access keys are rotated within the number of days specified in maxAccessKeyAge. The rule is NON_COMPLIANT if the access keys have not been rotated for more than maxAccessKeyAge number of days."
        input_parameters = {
          maxAccessKeyAge : "90"
        }
        enabled = true
        tags = {}
      }
    }
    ```
  DOC
  type = map(object({
    description      = string
    identifier       = string
    input_parameters = any
    tags             = map(string)
    enabled          = bool
  }))
  default = {}
}

variable "default_scope" {
  type        = string
  description = "The default scope of the conformance pack. Valid values are `account` and `organization`."
  default     = "account"
  validation {
    condition     = var.default_scope == "account" || var.default_scope == "organization"
    error_message = "The scope must be either `account` or `organization`."
  }
}
