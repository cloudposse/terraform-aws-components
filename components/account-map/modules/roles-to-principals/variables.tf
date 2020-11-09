variable "region" {
  type        = string
  description = "AWS Region"
}

variable "role_map" {
  type        = map(list(string))
  description = "Map of account:[role, role...]. Use `*` as role for entire account"
}

variable "iam_role_arn_template" {
  type        = string
  default     = "arn:aws:iam::%s:role/%s-%s-%s-%s"
  description = "IAM Role ARN template"
}
