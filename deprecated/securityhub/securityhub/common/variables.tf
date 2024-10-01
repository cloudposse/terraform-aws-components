variable "region" {
  type        = string
  description = "AWS Region"
}

variable "account_map_tenant" {
  type        = string
  default     = ""
  description = "The tenant where the `account_map` component required by remote-state is deployed"
}

variable "root_account_stage" {
  type        = string
  default     = "root"
  description = "The stage name for the Organization root (management) account"
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

variable "central_resource_collector_account" {
  description = "The name of the account that is the centralized aggregation account"
  type        = string
}

variable "central_resource_collector_region" {
  description = "The region that collects findings"
  type        = string
}

variable "create_sns_topic" {
  description = "Flag to indicate whether an SNS topic should be created for notifications"
  type        = bool
  default     = false
}

variable "enable_default_standards" {
  description = "Flag to indicate whether default standards should be enabled"
  type        = bool
  default     = true
}

variable "enabled_standards" {
  description = <<DOC
  A list of standards to enable in the account.

  For example:
  - standards/aws-foundational-security-best-practices/v/1.0.0
  - ruleset/cis-aws-foundations-benchmark/v/1.2.0
  - standards/pci-dss/v/3.2.1
  - standards/cis-aws-foundations-benchmark/v/1.4.0
  DOC
  type        = set(string)
  default     = []
}

variable "admin_delegated" {
  type        = bool
  default     = false
  description = <<DOC
  A flag to indicate if the Security Hub Administrator account has been designated from the root account.

  This component should be applied with this variable set to `false`, then the securityhub/root component should be applied
  to designate the administrator account, then this component should be applied again with this variable set to `true`.
  DOC
}

variable "finding_aggregator_enabled" {
  description = <<-DOC
  Flag to indicate whether a finding aggregator should be created

  If you want to aggregate findings from one region, set this to `true`.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_finding_aggregator
  DOC

  type    = bool
  default = false
}

variable "finding_aggregator_linking_mode" {
  description = <<-DOC
  Linking mode to use for the finding aggregator.

  The possible values are:
    - `ALL_REGIONS` - Aggregate from all regions
    - `ALL_REGIONS_EXCEPT_SPECIFIED` - Aggregate from all regions except those specified in `var.finding_aggregator_regions`
    - `SPECIFIED_REGIONS` - Aggregate from regions specified in `var.finding_aggregator_regions`
  DOC
  type        = string
  default     = "ALL_REGIONS"
}

variable "finding_aggregator_regions" {
  description = <<-DOC
  A list of regions to aggregate findings from.

  This is only used if `finding_aggregator_enabled` is `true`.
  DOC
  type        = any
  default     = null
}
