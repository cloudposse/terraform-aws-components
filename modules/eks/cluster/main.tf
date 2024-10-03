locals {
  enabled     = module.this.enabled
  vpc_outputs = module.vpc.outputs

  attributes = flatten(concat(module.this.attributes, [var.color]))

  this_account_name = module.iam_roles.current_account_account_name

  role_map = { (local.this_account_name) = var.aws_team_roles_rbac[*].aws_team_role }

  aws_team_roles_auth = [for role in var.aws_team_roles_rbac : {
    rolearn = module.iam_arns.principals_map[local.this_account_name][role.aws_team_role]
    groups  = role.groups
  }]

  aws_team_roles_access_entry_map = {
    for role in local.aws_team_roles_auth : role.rolearn => {
      kubernetes_groups = role.groups
    }
  }

  ## For future reference, as we enhance support for EKS Policies
  ## and namespace limits, here are some examples of entries:
  #  access_entry_map = {
  #    "arn:aws:iam::<acct>:role/prefix-admin" = {
  #      access_policy_associations = {
  #        ClusterAdmin = {}
  #      }
  #    }
  #    "arn:aws:iam::<account>:role/prefix-observer" = {
  #      kubernetes_groups = ["view"]
  #    }
  #  }
  #
  #  access_entry_map = merge({ for role in local.aws_team_roles_auth : role.rolearn => {
  #    kubernetes_groups          = role.groups
  #  } }, {for role in module.eks_workers[*].workers_role_arn : role => {
  #    type = "EC2_LINUX"
  #  }})

  iam_roles_access_entry_map = {
    for role in var.map_additional_iam_roles : role.rolearn => {
      kubernetes_groups = role.groups
    }
  }

  iam_users_access_entry_map = {
    for role in var.map_additional_iam_users : role.rolearn => {
      kubernetes_groups = role.groups
    }
  }

  access_entry_map = merge(local.aws_team_roles_access_entry_map, local.aws_sso_access_entry_map, local.iam_roles_access_entry_map, local.iam_users_access_entry_map)

  # If Karpenter IAM role is enabled, give it access to the cluster to allow the nodes launched by Karpenter to join the EKS cluster
  karpenter_role_arn = one(aws_iam_role.karpenter[*].arn)

  linux_worker_role_arns = local.enabled ? concat(
    var.map_additional_worker_roles,
    # As of Karpenter v0.35.0, there is no entry in the official Karpenter documentation
    # stating how to configure Karpenter node roles via EKS Access Entries.
    # However, it is launching unmanaged worker nodes, so it makes sense that they
    # be configured as EC2_LINUX unmanaged worker nodes. Of course, this probably
    # does not work if they are Windows nodes, but at the moment, this component
    # probably has other deficiencies that would prevent it from working with Windows nodes,
    # so we will stick with just saying Windows is not supported until we have some need for it.
    local.karpenter_iam_role_enabled ? [local.karpenter_role_arn] : [],
  ) : []

  # For backwards compatibility, we need to add the unmanaged worker role ARNs, but
  # historically we did not care whether they were LINUX or WINDOWS.
  # Best we can do is guess that they are LINUX. The `eks-cluster` module
  # did not give them all the support needed to run Windows anyway.
  access_entries_for_nodes = length(local.linux_worker_role_arns) > 0 ? {
    EC2_LINUX = local.linux_worker_role_arns
  } : {}

  subnet_type_tag_key = var.subnet_type_tag_key != null ? var.subnet_type_tag_key : local.vpc_outputs.vpc.subnet_type_tag_key

  allowed_cidr_blocks = concat(
    var.allowed_cidr_blocks,
    [
      for k in keys(module.vpc_ingress) :
      module.vpc_ingress[k].outputs.vpc_cidr
    ]
  )

  vpc_id = local.vpc_outputs.vpc_id

  availability_zones_expanded = local.enabled && length(var.availability_zones) > 0 && length(var.availability_zone_ids) == 0 ? (
    (substr(
      var.availability_zones[0],
      0,
      length(var.region)
    ) == var.region) ? var.availability_zones : formatlist("${var.region}%s", var.availability_zones)
  ) : []

  short_region = module.utils.region_az_alt_code_maps["to_short"][var.region]

  availability_zone_ids_expanded = local.enabled && length(var.availability_zone_ids) > 0 ? (
    (substr(
      var.availability_zone_ids[0],
      0,
      length(local.short_region)
    ) == local.short_region) ? var.availability_zone_ids : formatlist("${local.short_region}%s", var.availability_zone_ids)
  ) : []

  # Create a map of AZ IDs to AZ names (and the reverse),
  # but fail safely, because AZ IDs are not always available.
  az_id_map = length(local.availability_zone_ids_expanded) > 0 ? try(zipmap(data.aws_availability_zones.default[0].zone_ids, data.aws_availability_zones.default[0].names), {}) : {}

  availability_zones_normalized = length(local.availability_zone_ids_expanded) > 0 ? [
    for v in local.availability_zone_ids_expanded : local.az_id_map[v]
  ] : local.availability_zones_expanded

  # Get only the public subnets that correspond to the AZs provided in `var.availability_zones`
  # `az_public_subnets_map` is a map of AZ names to list of public subnet IDs in the AZs
  # LEGACY SUPPORT for legacy VPC with no az_public_subnets_map
  public_subnet_ids = try(flatten([
    for k, v in local.vpc_outputs.az_public_subnets_map : v
    if contains(var.availability_zones, k) || length(var.availability_zones) == 0
    ]),
  local.vpc_outputs.public_subnet_ids)

  # Get only the private subnets that correspond to the AZs provided in `var.availability_zones`
  # `az_private_subnets_map` is a map of AZ names to list of private subnet IDs in the AZs
  # LEGACY SUPPORT for legacy VPC with no az_public_subnets_map
  private_subnet_ids = try(flatten([
    for k, v in local.vpc_outputs.az_private_subnets_map : v
    if contains(var.availability_zones, k) || length(var.availability_zones) == 0
    ]),
  local.vpc_outputs.private_subnet_ids)

  # Infer the availability zones from the private subnets if var.availability_zones is empty:
  availability_zones = local.enabled ? (length(local.availability_zones_normalized) == 0 ? keys(local.vpc_outputs.az_private_subnets_map) : local.availability_zones_normalized) : []
}

data "aws_availability_zones" "default" {
  count = length(local.availability_zone_ids_expanded) > 0 ? 1 : 0

  # Filter out Local Zones. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones#by-filter
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }

  lifecycle {
    postcondition {
      condition     = length(self.zone_ids) > 0
      error_message = "No availability zones IDs found in region ${var.region}. You must specify availability zones instead."
    }
  }
}

module "utils" {
  source  = "cloudposse/utils/aws"
  version = "1.3.0"
}

module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "4.1.0"

  region     = var.region
  attributes = local.attributes

  access_config            = var.access_config
  access_entry_map         = local.access_entry_map
  access_entries_for_nodes = local.access_entries_for_nodes


  allowed_security_group_ids   = var.allowed_security_groups
  allowed_cidr_blocks          = local.allowed_cidr_blocks
  cluster_log_retention_period = var.cluster_log_retention_period
  enabled_cluster_log_types    = var.enabled_cluster_log_types
  endpoint_private_access      = var.cluster_endpoint_private_access
  endpoint_public_access       = var.cluster_endpoint_public_access
  kubernetes_version           = var.cluster_kubernetes_version
  oidc_provider_enabled        = var.oidc_provider_enabled
  public_access_cidrs          = var.public_access_cidrs
  subnet_ids                   = var.cluster_private_subnets_only ? local.private_subnet_ids : concat(local.private_subnet_ids, local.public_subnet_ids)


  # EKS addons
  addons = local.addons

  addons_depends_on = var.addons_depends_on ? concat(
    [module.region_node_group], local.addons_depends_on,
    values(local.final_addon_service_account_role_arn_map)
  ) : null

  cluster_encryption_config_enabled                         = var.cluster_encryption_config_enabled
  cluster_encryption_config_kms_key_id                      = var.cluster_encryption_config_kms_key_id
  cluster_encryption_config_kms_key_enable_key_rotation     = var.cluster_encryption_config_kms_key_enable_key_rotation
  cluster_encryption_config_kms_key_deletion_window_in_days = var.cluster_encryption_config_kms_key_deletion_window_in_days
  cluster_encryption_config_kms_key_policy                  = var.cluster_encryption_config_kms_key_policy
  cluster_encryption_config_resources                       = var.cluster_encryption_config_resources

  context = module.this.context
}
