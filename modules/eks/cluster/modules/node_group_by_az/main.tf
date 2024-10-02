data "aws_subnets" "private" {
  count = local.enabled ? 1 : 0

  tags = {
    (var.cluster_context.subnet_type_tag_key) = "private"
  }

  filter {
    name   = "vpc-id"
    values = [var.cluster_context.vpc_id]
  }

  filter {
    name   = "availability-zone"
    values = [var.availability_zone]
  }
}

module "az_abbreviation" {
  source  = "cloudposse/utils/aws"
  version = "1.3.0"
}

locals {
  enabled         = module.this.enabled && length(var.availability_zone) > 0
  sentinel        = "~~"
  subnet_ids_test = coalescelist(flatten(data.aws_subnets.private[*].ids), [local.sentinel])
  subnet_ids      = local.subnet_ids_test[0] == local.sentinel ? null : local.subnet_ids_test
  az_map          = var.cluster_context.az_abbreviation_type == "short" ? module.az_abbreviation.region_az_alt_code_maps.to_short : module.az_abbreviation.region_az_alt_code_maps.to_fixed
  az_attribute    = local.az_map[var.availability_zone]

  before_cluster_joining_userdata = var.cluster_context.node_userdata.before_cluster_joining_userdata != null ? [trimspace(var.cluster_context.node_userdata.before_cluster_joining_userdata)] : []
  bootstrap_extra_args            = var.cluster_context.node_userdata.bootstrap_extra_args != null ? [trimspace(var.cluster_context.node_userdata.bootstrap_extra_args)] : []
  kubelet_extra_args              = var.cluster_context.node_userdata.kubelet_extra_args != null ? [trimspace(var.cluster_context.node_userdata.kubelet_extra_args)] : []
  after_cluster_joining_userdata  = var.cluster_context.node_userdata.after_cluster_joining_userdata != null ? [trimspace(var.cluster_context.node_userdata.after_cluster_joining_userdata)] : []

}

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "3.0.1"

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

  # node_userdata
  before_cluster_joining_userdata = local.enabled ? local.before_cluster_joining_userdata : []
  bootstrap_additional_options    = local.enabled ? local.bootstrap_extra_args : []
  kubelet_additional_options      = local.enabled ? local.kubelet_extra_args : []
  after_cluster_joining_userdata  = local.enabled ? local.after_cluster_joining_userdata : []


  block_device_map = local.enabled ? var.cluster_context.block_device_map : null

  # Prevent the node groups from being created before the Kubernetes aws-auth configMap
  module_depends_on = var.cluster_context.module_depends_on

  node_role_policy_arns = var.cluster_context.aws_ssm_agent_enabled ? ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"] : []

  context = module.this.context
}
