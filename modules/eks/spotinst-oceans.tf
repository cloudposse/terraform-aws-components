# locals {
#   ocean_names               = [for k, v in var.spotinst_oceans : k]
#   spotinst_enabled          = module.this.enabled && var.spotinst_enabled && length(local.ocean_names) > 0
#   spotinst_instance_profile = try(format(var.spotinst_instance_profile_pattern, module.this.namespace, module.this.environment, module.this.stage), "")
# }

# data "aws_ssm_parameter" "spotinst_token" {
#   count = local.spotinst_enabled ? 1 : 0
#   name  = var.spotinst_token_ssm_key
# }
# data "aws_ssm_parameter" "spotinst_account" {
#   count = local.spotinst_enabled ? 1 : 0
#   name  = var.spotinst_account_ssm_key
# }
# data "aws_iam_instance_profile" "spotinst_worker" {
#   count = local.spotinst_enabled ? 1 : 0
#   name  = local.spotinst_instance_profile
# }

# locals {
#   spotinst_account = local.spotinst_enabled ? data.aws_ssm_parameter.spotinst_account[0].value : null
#   spotinst_token   = local.spotinst_enabled ? data.aws_ssm_parameter.spotinst_token[0].value : null
#   # spotinst_account = data.aws_ssm_parameter.spotinst_account.value
#   # spotinst_token   = data.aws_ssm_parameter.spotinst_token.value
#   so_def = var.spotinst_ocean_defaults
# }

# module "spotinst_oceans" {
#   for_each = var.spotinst_oceans
#   enabled  = local.spotinst_enabled
#   source   = "cloudposse/eks-spotinst-ocean-nodepool/aws"
#   version  = "0.0.4"

#   attributes          = compact(concat(["spotinst", each.key], each.value.attributes == null ? local.so_def.attributes : each.value.attributes))
#   desired_capacity    = each.value.desired_group_size == null ? local.so_def.desired_group_size : each.value.desired_group_size
#   disk_size           = each.value.disk_size == null ? local.so_def.disk_size : each.value.disk_size
#   instance_types      = each.value.instance_types == null ? local.so_def.instance_types : each.value.instance_types
#   instance_profile    = local.spotinst_instance_profile
#   ami_type            = each.value.ami_type == null ? local.so_def.ami_type : each.value.ami_type
#   ami_release_version = each.value.ami_release_version == null ? local.so_def.ami_release_version : each.value.ami_release_version
#   # If ocean kubernetes version is null, use cluster_kubernetes_version
#   kubernetes_version = coalesce(each.value.kubernetes_version, local.so_def.kubernetes_version, var.cluster_kubernetes_version, module.eks_cluster.eks_cluster_version)
#   max_size           = each.value.max_group_size == null ? local.so_def.max_group_size : each.value.max_group_size
#   min_size           = each.value.min_group_size == null ? local.so_def.min_group_size : each.value.min_group_size
#   tags               = each.value.tags == null ? local.so_def.tags : each.value.tags

#   eks_cluster_id      = module.eks_cluster.eks_cluster_id
#   ocean_controller_id = module.eks_cluster.eks_cluster_id
#   region              = var.region
#   subnet_ids          = local.private_subnet_ids
#   security_group_ids  = [module.eks_cluster.eks_cluster_managed_security_group_id]

#   context = module.this.context
# }
