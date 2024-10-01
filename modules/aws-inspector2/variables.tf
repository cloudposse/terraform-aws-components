variable "region" {
  type        = string
  description = "AWS Region"
}

variable "auto_enable_ec2" {
  description = "Whether Amazon EC2 scans are automatically enabled for new members of the Amazon Inspector organization."
  type        = bool
  default     = true
}

variable "auto_enable_ecr" {
  description = "Whether Amazon ECR scans are automatically enabled for new members of the Amazon Inspector organization."
  type        = bool
  default     = true
}

variable "auto_enable_lambda" {
  description = "Whether Lambda Function scans are automatically enabled for new members of the Amazon Inspector organization."
  type        = bool
  default     = true
}

variable "account_map_tenant" {
  type        = string
  default     = "core"
  description = "The tenant where the `account_map` component required by remote-state is deployed"
}

variable "root_account_stage" {
  type        = string
  default     = "root"
  description = <<-DOC
  The stage name for the Organization root (management) account. This is used to lookup account IDs from account names
  using the `account-map` component.
  DOC
}

variable "global_environment" {
  type        = string
  default     = "gbl"
  description = "Global environment name"
}

variable "privileged" {
  type        = bool
  default     = false
  description = "true if the default provider already has access to the backend"
}

variable "organization_management_account_name" {
  type        = string
  default     = null
  description = "The name of the AWS Organization management account"
}

variable "member_association_excludes" {
  description = "List of account names to exclude from Amazon Inspector member association"
  type        = list(string)
  default     = []
}

variable "delegated_administrator_account_name" {
  type        = string
  default     = "security"
  description = "The name of the account that is the AWS Organization Delegated Administrator account"
}

variable "admin_delegated" {
  type        = bool
  default     = false
  description = <<DOC
  A flag to indicate if the AWS Organization-wide settings should be created. This can only be done after the GuardDuty
  Administrator account has already been delegated from the AWS Org Management account (usually 'root'). See the
  Deployment section of the README for more information.
  DOC
}
