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

variable "central_resource_collector_account" {
  description = "The name of the account that is the centralized aggregation account"
  type        = string
}

variable "admin_delegated" {
  type        = bool
  default     = true
  description = <<DOC
  A flag to indicate if the GuardDuty Admininstrator account has been designated from the root account.

  This component should be applied with this variable set to false, then the guardduty-root component should be applied
  to designate the administrator account, then this component should be applied again with this variable set to `true`. 
  DOC
}

variable "finding_publishing_frequency" {
  description = <<-DOC
  The frequency of notifications sent for finding occurrences. If the detector is a GuardDuty member account, the value
  is determined by the GuardDuty master account and cannot be modified, otherwise it defaults to SIX_HOURS.

  For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection.
  Valid values for standalone and master accounts: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html#guardduty_findings_cloudwatch_notification_frequency
  DOC
  type        = string
  default     = null
}

variable "create_sns_topic" {
  description = <<-DOC
  Flag to indicate whether an SNS topic should be created for notifications.
  If you want to send findings to a new SNS topic, set this to true and provide a valid configuration for subscribers.
  DOC

  type    = bool
  default = false
}

variable "findings_notification_arn" {
  description = <<-DOC
  The ARN for an SNS topic to send findings notifications to. This is only used if create_sns_topic is false.
  If you want to send findings to an existing SNS topic, set the value of this to the ARN of the existing topic and set
  create_sns_topic to false.
  DOC
  default     = null
  type        = string
}

variable "subscribers" {
  type = map(object({
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = bool
    raw_message_delivery   = bool
  }))
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
    false
  raw_message_delivery:
    Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property).
    Default is false
  DOC
  default     = {}
}

variable "enable_cloudwatch" {
  description = <<-DOC
  Flag to indicate whether an CloudWatch logging should be enabled for GuardDuty
  DOC
  type        = bool
  default     = false
}

variable "cloudwatch_event_rule_pattern_detail_type" {
  description = <<-DOC
  The detail-type pattern used to match events that will be sent to SNS.

  For more information, see:
  https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html
  https://docs.aws.amazon.com/eventbridge/latest/userguide/event-types.html
  https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html
  DOC
  type        = string
  default     = "GuardDuty Finding"
}