module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.eks_component_name

  context = module.this.context
}

data "aws_eks_cluster" "kubernetes" {
  count = local.enabled ? 1 : 0

  name = module.eks.outputs.eks_cluster_id
}

data "aws_subnet" "vpc_subnets" {
  for_each = local.enabled ? data.aws_eks_cluster.kubernetes[0].vpc_config[0].subnet_ids : []

  id = each.value
}
