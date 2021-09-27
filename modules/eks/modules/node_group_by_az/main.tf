data "aws_subnet_ids" "private" {
  count = local.enabled ? 1 : 0

  vpc_id = var.cluster_context.vpc_id

  tags = {
    (var.cluster_context.subnet_type_tag_key) = "private"
  }

  filter {
    name   = "availability-zone"
    values = [var.availability_zone]
  }
}

module "az_abbreviation" {
  source  = "cloudposse/utils/aws"
  version = "0.3.0"
}

locals {
  enabled         = module.this.enabled && length(var.availability_zone) > 0
  sentinel        = "~~"
  subnet_ids_test = coalescelist(flatten(data.aws_subnet_ids.private[*].ids), [local.sentinel])
  subnet_ids      = local.subnet_ids_test[0] == local.sentinel ? null : local.subnet_ids_test
  az_map          = var.cluster_context.az_abbreviation_type == "short" ? module.az_abbreviation.region_az_alt_code_maps.to_short : module.az_abbreviation.region_az_alt_code_maps.to_fixed
  az_attribute    = local.az_map[var.availability_zone]
}

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.19.0"

  enabled = local.enabled

  attributes = length(var.availability_zone) > 0 ? flatten([module.this.attributes, local.az_attribute]) : module.this.attributes

  desired_size = local.enabled ? var.node_group_size.desired_size : null
  min_size     = local.enabled ? var.node_group_size.min_size : null
  max_size     = local.enabled ? var.node_group_size.max_size : null

  cluster_name                            = local.enabled ? var.cluster_context.cluster_name : null
  create_before_destroy                   = local.enabled ? var.cluster_context.create_before_destroy : null
  disk_size                               = local.enabled ? var.cluster_context.disk_size : null
  cluster_autoscaler_enabled              = local.enabled ? var.cluster_context.cluster_autoscaler_enabled : null
  instance_types                          = local.enabled ? var.cluster_context.instance_types : null
  ami_type                                = local.enabled ? var.cluster_context.ami_type : null
  ami_release_version                     = local.enabled ? var.cluster_context.ami_release_version : null
  capacity_type                           = local.enabled ? var.cluster_context.capacity_type : null
  kubernetes_labels                       = local.enabled ? var.cluster_context.kubernetes_labels : null
  kubernetes_taints                       = local.enabled ? var.cluster_context.kubernetes_taints : null
  kubernetes_version                      = local.enabled ? var.cluster_context.kubernetes_version : null
  launch_template_disk_encryption_enabled = local.enabled ? var.cluster_context.disk_encryption_enabled : null
  resources_to_tag                        = local.enabled ? var.cluster_context.resources_to_tag : null
  subnet_ids                              = local.enabled ? local.subnet_ids : null
  # Prevent the node groups from being created before the Kubernetes aws-auth configMap
  module_depends_on = var.cluster_context.module_depends_on

  context = module.this.context
}
