module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.eks_component_name

  context = module.this.context

  # Attempt to allow this component to be deleted from Terraform state even after the EKS cluster has been deleted
  defaults = {
    eks_cluster_id                   = "deleted"
    eks_cluster_arn                  = "deleted"
    eks_cluster_identity_oidc_issuer = "deleted"
    karpenter_node_role_arn          = "deleted"
  }
}
