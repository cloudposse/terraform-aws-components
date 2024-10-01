variable "region" {
  type        = string
  description = "AWS Region"
}

variable "cloudwatch_event_rule_description" {
  type        = string
  description = "Description of the CloudWatch Event Rule. If empty, will default to `module.this.id`"
  default     = ""
}

variable "cloudwatch_event_rule_pattern" {
  type        = any
  description = "Pattern of the CloudWatch Event Rule"
  default = {
    "source" = [
      "aws.ec2"
    ]
  }
}

variable "event_log_retention_in_days" {
  type        = number
  description = "Number of days to retain the event logs"
  default     = 3
}
