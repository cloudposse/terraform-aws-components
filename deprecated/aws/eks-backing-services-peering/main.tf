# Lookup the EKS VPC
data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}${var.delimiter}${var.stage}${var.delimiter}${var.name}"]
  }
}

# Lookup the backing services VPC
data "aws_vpc" "backing_services_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}${var.delimiter}${var.stage}${var.delimiter}backing-services"]
  }
}

module "vpc_peering" {
  source           = "git::https://github.com/cloudposse/terraform-aws-vpc-peering.git?ref=tags/0.1.2"
  namespace        = var.namespace
  stage            = var.stage
  name             = var.name
  delimiter        = var.delimiter
  attributes       = ["${compact(concat(var.attributes, list("peering")))}"]
  tags             = var.tags
  requester_vpc_id = data.aws_vpc.eks_vpc.id
  acceptor_vpc_id  = data.aws_vpc.backing_services_vpc.id
}
