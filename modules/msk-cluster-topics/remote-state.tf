module "msk_cluster" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component = var.msk_cluster_component

  context = module.this.context
}
