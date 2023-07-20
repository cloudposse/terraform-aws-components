data "aws_subnets" "private" {
  count = local.enabled ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.cluster_context.vpc_id]
  }

  filter {
    name   = "availability-zone"
    values = [var.availability_zone]
  }

  tags = {
    (var.cluster_context.subnet_type_tag_key) = "private"
  }
}

module "az_abbreviation" {
  source  = "cloudposse/utils/aws"
  version = "0.8.1"
}

locals {
  enabled         = module.this.enabled && length(var.availability_zone) > 0
  sentinel        = "~~"
  subnet_ids_test = coalescelist(flatten(data.aws_subnets.private[*].ids), [local.sentinel])
  subnet_ids      = local.subnet_ids_test[0] == local.sentinel ? null : local.subnet_ids_test
  az_map          = var.cluster_context.az_abbreviation_type == "short" ? module.az_abbreviation.region_az_alt_code_maps.to_short : module.az_abbreviation.region_az_alt_code_maps.to_fixed
  az_attribute    = local.az_map[var.availability_zone]
}

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.27.0"

  enabled = local.enabled

  attributes = length(var.availability_zone) > 0 ? flatten([module.this.attributes, local.az_attribute]) : module.this.attributes

  desired_size = local.enabled ? var.node_group_size.desired_size : null
  min_size     = local.enabled ? var.node_group_size.min_size : null
  max_size     = local.enabled ? var.node_group_size.max_size : null

  # NOTE: the following values are using the migration pattern outlined
  # https://github.com/cloudposse/terraform-aws-eks-node-group/blob/34be126797af6673ca0375d6e60bca5616257786/MIGRATION.md#block_device_mappings

  cluster_name               = local.enabled ? var.cluster_context.cluster_name : null
  create_before_destroy      = local.enabled ? var.cluster_context.create_before_destroy : null
  cluster_autoscaler_enabled = local.enabled ? var.cluster_context.cluster_autoscaler_enabled : null
  instance_types             = local.enabled ? var.cluster_context.instance_types : null
  ami_type                   = local.enabled ? var.cluster_context.ami_type : null
  ami_release_version        = local.enabled && length(compact([var.cluster_context.ami_release_version])) != 0 ? [var.cluster_context.ami_release_version] : []
  kubernetes_labels          = local.enabled ? var.cluster_context.kubernetes_labels : null
  kubernetes_taints          = local.enabled ? var.cluster_context.kubernetes_taints : []
  kubernetes_version         = local.enabled && length(compact([var.cluster_context.kubernetes_version])) != 0 ? [var.cluster_context.kubernetes_version] : []
  resources_to_tag           = local.enabled ? var.cluster_context.resources_to_tag : null
  subnet_ids                 = local.enabled ? local.subnet_ids : null

  block_device_mappings = local.enabled ? [{
    device_name           = "/dev/xvda"
    volume_size           = var.cluster_context.disk_size
    volume_type           = "gp2"
    encrypted             = var.cluster_context.disk_encryption_enabled
    delete_on_termination = true
  }] : []

  # Prevent the node groups from being created before the Kubernetes aws-auth configMap
  module_depends_on = var.cluster_context.module_depends_on

  node_role_policy_arns = var.cluster_context.aws_ssm_agent_enabled ? ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"] : []

  context = module.this.context
}
