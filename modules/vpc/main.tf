locals {
  enabled = module.this.enabled

  ec2_endpoint_enabled                  = local.enabled && var.ec2_vpc_endpoint_enabled
  nat_eip_aws_shield_protection_enabled = local.enabled && var.nat_eip_aws_shield_protection_enabled
  vpc_flow_logs_enabled                 = local.enabled && var.vpc_flow_logs_enabled
  ipam_enabled                          = local.enabled && try(length(var.ipv4_primary_cidr_block), 0) == 0

  # The usage of the specific kubernetes.io/cluster/* resource tags below are required
  # for EKS and Kubernetes to discover and manage networking resources
  # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
  tags = var.eks_tags_enabled ? { for eks in module.eks : format("kubernetes.io/cluster/%s", eks.outputs.eks_cluster_id) => "shared" } : {}

  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : var.region_availability_zones

  max_subnet_count = (
    var.max_subnet_count > 0 ? var.max_subnet_count : (
      length(var.region_availability_zones) > 0 ? length(var.region_availability_zones) : length(var.availability_zones)
    )
  )

  # required tags to make ALB ingress work https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
  # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  public_subnets_additional_tags = {
    (var.subnet_type_tag_key) = "public",
    "kubernetes.io/role/elb"  = 1,
  }

  private_subnets_additional_tags = {
    (var.subnet_type_tag_key)         = "private",
    "kubernetes.io/role/internal-elb" = 1,
  }
}

data "aws_vpc_ipam_pool" "current" {
  count = local.ipam_enabled ? 1 : 0
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "1.1.0"

  tags                    = local.tags
  ipv4_primary_cidr_block = var.ipv4_primary_cidr_block

  ipv4_primary_cidr_block_association = local.ipam_enabled ? merge(
    var.ipv4_primary_cidr_block_association,
    {
      ipv4_ipam_pool_id = join("", data.aws_vpc_ipam_pool.current.*.id)
    }
  ) : null

  context = module.this.context
}

module "ec2_vpc_endpoint_sg_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled = local.ec2_endpoint_enabled

  attributes = ["ec2-vpc-endpoint-sg"]

  context = module.this.context
}

resource "aws_security_group" "ec2_vpc_endpoint_sg" {
  count = local.ec2_endpoint_enabled ? 1 : 0

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Security Group for EC2 Interface VPC Endpoint"
  }

  tags = module.ec2_vpc_endpoint_sg_label.tags
}

module "vpc_endpoints" {
  source  = "cloudposse/vpc/aws//modules/vpc-endpoints"
  version = "1.1.0"

  enabled = local.ec2_endpoint_enabled

  vpc_id = module.vpc.vpc_id
  interface_vpc_endpoints = {
    ec2 = {
      name                = "ec2"
      security_group_ids  = [join("", aws_security_group.ec2_vpc_endpoint_sg.*.id)]
      subnet_ids          = module.subnets.private_subnet_ids
      policy              = null
      private_dns_enabled = true
    }
  }

  tags = module.ec2_vpc_endpoint_sg_label.tags
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.0.2"

  tags = local.tags

  availability_zones              = local.availability_zones
  ipv4_cidr_block                 = [module.vpc.vpc_cidr_block]
  igw_id                          = [module.vpc.igw_id]
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  max_subnet_count                = local.max_subnet_count
  nat_gateway_enabled             = var.nat_gateway_enabled
  nat_instance_enabled            = var.nat_instance_enabled
  nat_instance_type               = var.nat_instance_type
  public_subnets_additional_tags  = local.public_subnets_additional_tags
  private_subnets_additional_tags = local.private_subnets_additional_tags
  vpc_id                          = module.vpc.vpc_id

  context = module.this.context
}

data "aws_caller_identity" "current" {
  count = local.nat_eip_aws_shield_protection_enabled ? 1 : 0
}

data "aws_eip" "eip" {
  for_each = local.nat_eip_aws_shield_protection_enabled ? toset(module.subnets.nat_ips) : []

  public_ip = each.key
}

resource "aws_shield_protection" "nat_eip_shield_protection" {
  for_each = local.nat_eip_aws_shield_protection_enabled ? data.aws_eip.eip : {}

  name         = data.aws_eip.eip[each.key].id
  resource_arn = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current[0].account_id}:eip-allocation/${data.aws_eip.eip[each.key].id}"
}
