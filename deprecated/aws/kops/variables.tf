variable "aws_assume_role_arn" {
  type = string
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = string
  description = "Name  (e.g. `kops`)"
  default     = "kops"
}

variable "region" {
  type        = string
  default     = ""
  description = "AWS region for resources. Can be overridden by `resource_region` and `state_store_region`"
}

variable "state_store_region" {
  type        = string
  default     = ""
  description = "Region where to create the S3 bucket for the kops state store. Defaults to `var.region`"
}

variable "resource_region" {
  type        = string
  default     = ""
  description = "Region where to create region-specific resources. Defaults to `var.region`"
}

variable "create_state_store_bucket" {
  type        = string
  default     = "true"
  description = "Set to `false` to use existing S3 bucket (e.g. from another region)"
}

variable "cluster_name_prefix" {
  type        = string
  default     = ""
  description = "Prefix to add before parent DNS zone name to identify this cluster, e.g. `us-east-1`. Defaults to `var.resource_region`"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones in which to provision the cluster (should be an odd number to avoid split-brain)."
  default     = []
}

variable "availability_zone_count" {
  description = "Number of availability zones to use (to provision the kops cluster in)"
  default     = "3"
}

variable "zone_name" {
  type        = string
  description = "DNS zone name"
}

variable "domain_enabled" {
  type        = string
  description = "Enable DNS Zone creation for kops"
  default     = "true"
}

variable "force_destroy" {
  type        = string
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without errors. These objects are not recoverable."
  default     = "false"
}

variable "ssh_key_algorithm" {
  type        = string
  default     = "RSA"
  description = "SSH key algorithm to use. Currently-supported values are 'RSA' and 'ECDSA'"
}

variable "ssh_key_rsa_bits" {
  type        = string
  description = "When ssh_key_algorithm is 'RSA', the size of the generated RSA key in bits"
  default     = "4096"
}

variable "ssh_key_ecdsa_curve" {
  type        = string
  description = "When ssh_key_algorithm is 'ECDSA', the name of the elliptic curve to use. May be any one of 'P256', 'P384' or P521'"
  default     = "P521"
}

variable "kops_attribute" {
  type        = string
  description = "Additional attribute to kops state bucket"
  default     = "state"
}

variable "complete_zone_name" {
  type        = string
  description = "Region or any classifier prefixed to zone name"
  default     = "$${name}.$${parent_zone_name}"
}

variable "network_cidr" {
  description = "This is the CIDR block of your virtual network"
  default     = "172.20.0.0/16"
}

# Read more: <https://kubernetes.io/docs/tasks/administer-cluster/ip-masq-agent/#key-terms>
variable "kops_non_masquerade_cidr" {
  description = "The CIDR range for Pod IPs."
  default     = "100.64.0.0/10"
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

variable "create_vpc" {
  default     = "true"
  description = "Set to false to use VPC specified in Chamber VPC parameters, true to create a new VPC"
}

variable "use_shared_nat_gateways" {
  default     = "false"
  description = "Set true if shared VPC use NAT gateways"
}

variable "vpc_chamber_service" {
  default     = "vpc"
  description = "`chamber` service name where shared vpc parameters are stored"
}

variable "vpc_chamber_parameter_name" {
  default = "/%s/%s_%s"
}

variable "vpc_parameter_prefix" {
  default     = "vpc_common"
  description = "parameter name prefix to use when looking up VPC parameters in chamber"
}
