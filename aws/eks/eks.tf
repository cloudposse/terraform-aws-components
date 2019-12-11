module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, list("cluster")))
  tags       = var.tags
}

locals {
  tags = merge(module.label.tags, map("kubernetes.io/cluster/${module.label.id}", "shared"))
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.8.1"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = var.attributes
  cidr_block = var.vpc_cidr_block
  tags       = local.tags
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.18.1"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  attributes           = var.attributes
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false
  tags                 = local.tags
}

module "eks_cluster" {
  source                = "git::https://github.com/cloudposse/terraform-aws-eks-cluster.git?ref=tags/0.13.0"
  namespace             = var.namespace
  stage                 = var.stage
  name                  = var.name
  attributes            = var.attributes
  tags                  = var.tags
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.subnets.public_subnet_ids
  kubernetes_version    = var.kubernetes_version
  kubeconfig_path       = var.kubeconfig_path
  oidc_provider_enabled = var.oidc_provider_enabled

  workers_role_arns          = [module.eks_node_group.eks_node_group_role_arn]
  workers_security_group_ids = []
}

module "eks_node_group" {
  source             = "git::https://github.com/cloudposse/terraform-aws-eks-node-group.git?ref=tags/0.1.0"
  namespace          = var.namespace
  stage              = var.stage
  name               = var.name
  attributes         = var.attributes
  tags               = var.tags
  subnet_ids         = module.subnets.public_subnet_ids
  instance_types     = var.instance_types
  desired_size       = var.desired_size
  min_size           = var.min_size
  max_size           = var.max_size
  cluster_name       = module.eks_cluster.eks_cluster_id
  kubernetes_version = var.kubernetes_version
  kubernetes_labels  = var.kubernetes_labels
}

locals {
  chamber_service = var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service
}

resource "aws_ssm_parameter" "eks_cluster_id" {
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "eks_cluster_id")
  value       = module.eks_cluster.eks_cluster_id
  description = "EKS cluster ID"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "eks_cluster_identity_oidc_issuer" {
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "eks_cluster_identity_oidc_issuer")
  value       = module.eks_cluster.eks_cluster_identity_oidc_issuer
  description = "EKS cluster identity OIDC issuer"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "eks_cluster_endpoint" {
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "eks_cluster_endpoint")
  value       = module.eks_cluster.eks_cluster_endpoint
  description = "EKS cluster endpoint"
  type        = "String"
  overwrite   = true
}
