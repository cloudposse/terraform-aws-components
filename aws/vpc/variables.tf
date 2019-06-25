variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Name to distinguish this VPC from others in this account"
  default     = "vpc"
}

variable "attributes" {
  type        = "list"
  description = "Additional attributes to distinguish this VPC from others in this account"
  default     = ["common"]
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "max_subnet_count" {
  default     = 0
  description = "Sets the maximum amount of subnets to deploy.  0 will deploy a subnet for every provided availablility zone (in `availability_zones` variable) within the region"
}

variable "availability_zones" {
  type        = "list"
  default     = []
  description = "List of Availability Zones where subnets will be created. If empty, all zones will be used"
}

variable "vpc_nat_gateway_enabled" {
  description = "Flag to enable/disable NAT Gateways to allow servers in the private subnets to access the Internet"
  default     = "true"
}

variable "vpc_nat_instance_enabled" {
  description = "Flag to enable/disable NAT Instances to allow servers in the private subnets to access the Internet"
  default     = "false"
}

variable "vpc_nat_instance_type" {
  description = "NAT Instance type"
  default     = "t3.micro"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags, for example map(`KubernetesCluster`,`us-west-2.prod.example.com`)"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "chamber_service" {
  default     = ""
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "chamber_parameter_name" {
  description = "format string for creating SSM parameter name used to store chamber parameters"
  default     = "/%s/%s_%s"
}
