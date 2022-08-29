variable "region" {
  type        = string
  description = "AWS Region"
}

variable "minimum_password_length" {
  type        = string
  default     = 14
  description = "Minimum number of characters allowed in an IAM user password. Integer between 6 and 128, per https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_account-policy.html"
}

variable "maximum_password_age" {
  type        = number
  default     = 190
  description = "The number of days that an user password is valid"
}

variable "budgets_enabled" {
  type        = bool
  description = "Whether or not this component should manage AWS Budgets"
  default     = false
}

variable "budgets" {
  type        = any
  description = <<-EOF
  A list of Budgets to be managed by this module, see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget#argument-reference
  for a list of possible attributes. For a more specific example, see `https://github.com/cloudposse/terraform-aws-budgets/blob/master/examples/complete/fixtures.us-east-2.tfvars`.
  EOF
  default     = []
}

variable "budgets_notifications_enabled" {
  type        = bool
  description = "Whether or not to setup Slack notifications for Budgets. Set to `true` to create an SNS topic and Lambda function to send alerts to a Slack channel."
  default     = false
}

variable "budgets_slack_webhook_url" {
  type        = string
  description = "The URL of Slack webhook. Only used when `budgets_notifications_enabled` is `true`"
  default     = ""
}

variable "budgets_slack_channel" {
  type        = string
  description = "The name of the channel in Slack for notifications. Only used when `budgets_notifications_enabled` is `true`"
  default     = ""
}

variable "budgets_slack_username" {
  type        = string
  description = "The username that will appear on Slack messages. Only used when `budegets_notifications_enabled` is `true`"
  default     = ""
}

variable "service_quotas_enabled" {
  type        = bool
  default     = false
  description = "Whether or not this component should handle Service Quotas"
}

variable "service_quotas" {
  type        = list(any)
  default     = []
  description = <<-EOF
  A list of service quotas to manage or lookup.
  To lookup the value of a service quota, set `value = null` and either `quota_code` or `quota_name`.
  To manage a service quota, set `value` to a number. Service Quotas can only be managed via `quota_code`.
  For a more specific example, see https://github.com/cloudposse/terraform-aws-service-quotas/blob/master/examples/complete/fixtures.us-east-2.tfvars.
  EOF
}
