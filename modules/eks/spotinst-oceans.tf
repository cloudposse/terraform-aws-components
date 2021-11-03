# NOTE: This is commented out because spot.io provider cannot be disabled with an input variable.

# locals {
#   spotinst_instance_profile = (
#     var.spotinst_instance_profile_pattern == null || var.spotinst_instance_profile_pattern == "" ?
#     null : format(var.spotinst_instance_profile_pattern, var.namespace, var.tenant, var.environment, var.stage)
#   )
# }

# data "aws_ssm_parameter" "spotinst_token" {
#   count    = local.spotinst_enabled ? 1 : 0
#   provider = aws.spotinst_secrets
#   name     = var.spotinst_token_ssm_key
# }

# data "aws_ssm_parameter" "spotinst_account" {
#   count    = local.spotinst_enabled ? 1 : 0
#   provider = aws.spotinst_secrets
#   name     = var.spotinst_account_ssm_key
# }

# locals {
#   spotinst_account = local.spotinst_enabled ? data.aws_ssm_parameter.spotinst_account[0].value : null
#   spotinst_token   = local.spotinst_enabled ? data.aws_ssm_parameter.spotinst_token[0].value : null
#   so_def           = var.spotinst_ocean_defaults
# }

# module "spotinst_oceans" {
#   for_each = local.enabled ? var.spotinst_oceans : {}
#   enabled  = local.spotinst_enabled
#   source   = "cloudposse/eks-spotinst-ocean-nodepool/aws"
#   version  = "0.4.2"

#   attributes          = compact(concat(["spotinst", each.key], each.value.attributes == null ? local.so_def.attributes : each.value.attributes))
#   desired_capacity    = each.value.desired_group_size == null ? local.so_def.desired_group_size : each.value.desired_group_size
#   disk_size           = each.value.disk_size == null ? local.so_def.disk_size : each.value.disk_size
#   instance_types      = each.value.instance_types == null ? local.so_def.instance_types : each.value.instance_types
#   instance_profile    = local.spotinst_instance_profile
#   ami_type            = each.value.ami_type == null ? local.so_def.ami_type : each.value.ami_type
#   ami_release_version = each.value.ami_release_version == null ? local.so_def.ami_release_version : each.value.ami_release_version
#   # If ocean kubernetes version is null, use cluster_kubernetes_version. If no EKS cluster version, it must be disabled, use "1.1" to keep `coalesce` happy
#   kubernetes_version = coalesce(each.value.kubernetes_version, local.so_def.kubernetes_version, var.cluster_kubernetes_version, module.eks_cluster.eks_cluster_version, "1.1")
#   max_size           = each.value.max_group_size == null ? local.so_def.max_group_size : each.value.max_group_size
#   min_size           = each.value.min_group_size == null ? local.so_def.min_group_size : each.value.min_group_size
#   tags               = each.value.tags == null ? local.so_def.tags : each.value.tags

#   eks_cluster_id      = module.eks_cluster.eks_cluster_id
#   ocean_controller_id = module.eks_cluster.eks_cluster_id
#   region              = var.region
#   subnet_ids          = local.private_subnet_ids
#   security_group_ids  = [module.eks_cluster.eks_cluster_managed_security_group_id]

#   update_policy_should_roll           = var.update_policy_should_roll
#   update_policy_batch_size_percentage = var.update_policy_batch_size_percentage

#   context = module.this.context
# }
