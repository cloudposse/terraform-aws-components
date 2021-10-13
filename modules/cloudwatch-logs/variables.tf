variable "region" {
  type        = string
  description = "AWS Region"
}

variable "retention_in_days" {
  description = "Number of days you want to retain log events in the log group"
  default     = "30"
}

variable "stream_names" {
  default     = []
  type        = list(string)
  description = "Names of streams"
}

variable "principals" {
  type        = map(any)
  description = "Map of service name as key and a list of ARNs to allow assuming the role as value. (e.g. map(`AWS`, list(`arn:aws:iam:::role/admin`)))"

  default = {
    Service = ["ecs.amazonaws.com"]
  }
}

variable "additional_permissions" {
  default = [
    "logs:CreateLogStream",
    "logs:DeleteLogStream",
  ]

  type        = list(string)
  description = "Additional permissions granted to assumed role"
}
