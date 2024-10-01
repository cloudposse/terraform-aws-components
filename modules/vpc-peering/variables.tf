variable "region" {
  type        = string
  description = "AWS Region"
}

variable "auto_accept" {
  type        = bool
  default     = true
  description = "Automatically accept peering request"
}

variable "accepter_allow_remote_vpc_dns_resolution" {
  type        = bool
  description = "Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC"
  default     = true
}

variable "accepter_aws_assume_role_arn" {
  type        = string
  description = "Accepter AWS assume role ARN"
  default     = null
}

variable "accepter_region" {
  type        = string
  description = "Accepter AWS region"
}

variable "accepter_vpc" {
  type        = any
  description = "Accepter VPC map of id, cidr_block, or default arguments for the data source"
}

variable "accepter_stage_name" {
  type        = string
  description = "Accepter stage name if in v1"
  default     = null
}

variable "requester_vpc_id" {
  type        = string
  description = "Requester VPC ID, if not provided, it will be looked up by component using variable `requester_vpc_component_name`"
  default     = null
}

variable "requester_role_arn" {
  type        = string
  description = "Requester AWS assume role ARN, if not provided it will be assumed to be the current terraform role."
  default     = null
}

variable "requester_allow_remote_vpc_dns_resolution" {
  type        = bool
  description = "Allow requester VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the accepter VPC"
  default     = true
}

variable "requester_vpc_component_name" {
  type        = string
  description = "Requester vpc component name"
  default     = "vpc"
}
