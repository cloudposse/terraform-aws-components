variable "region" {
  type = string
}

variable "client_cidr" {
  type = string
}

variable "aws_subnet_id" {
  type = string
}

variable "aws_authorization_rule_target_cidr" {
  type = string
}

variable "logging_enabled" {
  type = bool
}

variable "logs_retention" {
  type = number
}

variable "internet_access_enabled" {
  type = bool
}

variable "organization_name" {
  type = string
}