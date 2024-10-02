variable "account_map_tenant" {
  type        = string
  default     = "core"
  description = "The tenant where the `account_map` component required by remote-state is deployed"
}

variable "admin_delegated" {
  type        = bool
  default     = false
  description = <<DOC
  A flag to indicate if the AWS Organization-wide settings should be created. This can only be done after the Security
  Hub Administrator account has already been delegated from the AWS Org Management account (usually 'root'). See the
  Deployment section of the README for more information.
  DOC
}

variable "auto_enable_organization_members" {
  type        = bool
  default     = true
  description = <<-DOC
  Flag to toggle auto-enablement of Security Hub for new member accounts in the organization.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_configuration#auto_enable
  DOC

}

variable "cloudwatch_event_rule_pattern_detail_type" {
  type        = string
  default     = "ecurity Hub Findings - Imported"
  description = <<-DOC
  The detail-type pattern used to match events that will be sent to SNS.

  For more information, see:
  https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html
  https://docs.aws.amazon.com/eventbridge/latest/userguide/event-types.html
  DOC
}

variable "create_sns_topic" {
  type        = bool
  default     = false
  description = <<-DOC
  Flag to indicate whether an SNS topic should be created for notifications. If you want to send findings to a new SNS
  topic, set this to true and provide a valid configuration for subscribers.
  DOC
}

variable "default_standards_enabled" {
  description = "Flag to indicate whether default standards should be enabled"
  type        = bool
  default     = true
}

variable "delegated_administrator_account_name" {
  type        = string
  default     = "core-security"
  description = "The name of the account that is the AWS Organization Delegated Administrator account"
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

variable "finding_aggregation_region" {
  description = "If finding aggregation is enabled, the region that collects findings"
  type        = string
  default     = null
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

variable "findings_notification_arn" {
  default     = null
  type        = string
  description = <<-DOC
  The ARN for an SNS topic to send findings notifications to. This is only used if create_sns_topic is false.
  If you want to send findings to an existing SNS topic, set this to the ARN of the existing topic and set
  create_sns_topic to false.
  DOC
}

variable "global_environment" {
  type        = string
  default     = "gbl"
  description = "Global environment name"
}

variable "organization_management_account_name" {
  type        = string
  default     = null
  description = "The name of the AWS Organization management account"
}

variable "privileged" {
  type        = bool
  default     = false
  description = "true if the default provider already has access to the backend"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "root_account_stage" {
  type        = string
  default     = "root"
  description = <<-DOC
  The stage name for the Organization root (management) account. This is used to lookup account IDs from account names
  using the `account-map` component.
  DOC
}

variable "subscribers" {
  type = map(object({
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = bool
    raw_message_delivery   = bool
  }))
  default     = {}
  description = <<-DOC
  A map of subscription configurations for SNS topics

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#argument-reference

  protocol:
    The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially
    supported, see link) (email is an option but is unsupported in terraform, see link).
  endpoint:
    The endpoint to send data to, the contents will vary with the protocol. (see link for more information)
  endpoint_auto_confirms:
    Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty. Default is
    false.
  raw_message_delivery:
    Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not
    wrapped in JSON with the original message in the message property). Default is false.
  DOC
}
