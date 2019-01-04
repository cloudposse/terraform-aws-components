variable "aws_assume_role_arn" {
  type = "string"
}

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
  description = "Name  (e.g. `kops`)"
  default     = "kops"
}

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "availability_zones" {
  type        = "list"
  description = "List of availability zones in which to provision the cluster (should be an odd number to avoid split-brain)."
  default     = []
}

variable "availability_zone_count" {
  description = "Number of availability zones to use (to provision the kops cluster in)"
  default     = "3"
}

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

variable "domain_enabled" {
  type        = "string"
  description = "Enable DNS Zone creation for kops"
  default     = "true"
}

variable "force_destroy" {
  type        = "string"
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without errors. These objects are not recoverable."
  default     = "false"
}

variable "ssh_public_key_path" {
  type        = "string"
  description = "SSH public key path to write master public/private key pair for cluster"
  default     = "/secrets/tf/ssh"
}

variable "kops_attribute" {
  type        = "string"
  description = "Additional attribute to kops state bucket"
  default     = "state"
}

variable "complete_zone_name" {
  type        = "string"
  description = "Region or any classifier prefixed to zone name"
  default     = "$${name}.$${parent_zone_name}"
}

variable "network_cidr" {
  description = "This is the CIDR block of your virtual network"
  default     = "172.20.0.0/16"
}

variable "private_subnets_newbits" {
  description = "This is the new mask for the private subnet within the virtual network"
  default     = "-1"
}

variable "private_subnets_netnum" {
  description = "This is the zero-based index of the private subnet when the network is masked with the `newbit`"
  default     = "0"
}

variable "utility_subnets_newbits" {
  description = "This is the new mask for the utility subnet within the virtual network"
  default     = "-1"
}

variable "utility_subnets_netnum" {
  description = "This is the zero-based index of the utility subnet when the network is masked with the `newbit`"
  default     = "0"
}

variable "chamber_service" {
  default     = ""
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "chamber_parameter_name" {
  default = "/%s/%s"
}
