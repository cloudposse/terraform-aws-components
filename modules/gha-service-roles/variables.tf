variable "region" {
  type        = string
  description = "AWS Region"
}

variable "aws_iam_policy_statements" {
  type    = list(any)
  default = []
}
