module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-metadata.git?ref=tags/0.1.1"
  dns_zone     = "${var.kops_cluster_name}"
  masters_name = "${var.masters_name}"
  nodes_name   = "${var.nodes_name}"
}

variable "kops_cluster_name" {
  type        = "string"
  description = "Kops cluster name (e.g. `us-east-1.cloudposse.com` or `cluster-1.cloudposse.com`)"
}

variable "masters_name" {
  type        = "string"
  default     = "masters"
  description = "Kops masters subdomain name in the cluster DNS zone"
}

variable "nodes_name" {
  type        = "string"
  default     = "nodes"
  description = "Kops nodes subdomain name in the cluster DNS zone"
}
