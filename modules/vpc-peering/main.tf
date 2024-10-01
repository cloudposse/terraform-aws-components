locals {
  enabled = module.this.enabled

  requester_vpc_id = coalesce(var.requester_vpc_id, one(module.requester_vpc[*].outputs.vpc_id))

  accepter_aws_assume_role_arn = var.accepter_stage_name != null ? module.iam_roles.terraform_role_arns[var.accepter_stage_name] : var.accepter_aws_assume_role_arn
}

data "aws_vpc" "accepter" {
  count = local.enabled ? 1 : 0

  provider = aws.accepter

  id         = lookup(var.accepter_vpc, "id", null)
  cidr_block = lookup(var.accepter_vpc, "cidr_block", null)
  default    = lookup(var.accepter_vpc, "default", null)
  tags       = lookup(var.accepter_vpc, "tags", null)
}

module "vpc_peering" {
  source  = "cloudposse/vpc-peering-multi-account/aws"
  version = "0.19.1"

  auto_accept = var.auto_accept

  requester_allow_remote_vpc_dns_resolution = var.requester_allow_remote_vpc_dns_resolution
  requester_aws_assume_role_arn             = coalesce(var.requester_role_arn, module.iam_roles.terraform_role_arn)
  requester_region                          = var.region
  requester_vpc_id                          = local.requester_vpc_id

  accepter_allow_remote_vpc_dns_resolution = var.accepter_allow_remote_vpc_dns_resolution
  accepter_aws_assume_role_arn             = local.accepter_aws_assume_role_arn
  accepter_region                          = var.accepter_region
  accepter_vpc_id                          = one(data.aws_vpc.accepter[*].id)

  context = module.this.context
}
