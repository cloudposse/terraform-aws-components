variable "region" {
  type        = string
  description = "AWS Region"
}

variable "ssm_path_prefix" {
  type        = string
  description = "Top level SSM path prefix (without leading or trailing slash)"
}
