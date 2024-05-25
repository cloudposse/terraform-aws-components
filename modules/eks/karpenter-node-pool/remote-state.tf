module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.eks_component_name

  defaults = {
    eks_cluster_id                   = "deleted"
    eks_cluster_arn                  = "deleted"
    eks_cluster_identity_oidc_issuer = "deleted"
    karpenter_node_role_arn          = "deleted"
  }

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "vpc"

  context = module.this.context
}
