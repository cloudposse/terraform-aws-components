variable "aws_assume_role_arn" {
  type = string
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `audit`)"
  default     = "audit"
}

variable "name" {
  type        = string
  description = "Name (e.g. `account`)"
  default     = "account"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = ""
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Number of days to retain logs for. CIS recommends 365 days.  Possible/ values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. Set to 0 to keep logs indefinitely."
  default     = 365
}
