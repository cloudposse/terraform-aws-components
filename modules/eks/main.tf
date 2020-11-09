locals {
  primary_role_map   = data.terraform_remote_state.primary_roles.outputs.role_name_role_arn_map
  delegated_role_map = data.terraform_remote_state.delegated_roles.outputs.role_name_role_arn_map
  eks_outputs        = data.terraform_remote_state.eks.outputs
  vpc_outputs        = data.terraform_remote_state.vpc.outputs

  attributes         = flatten(concat(module.this.attributes, [var.color]))
  public_subnet_ids  = local.vpc_outputs.public_subnet_ids
  private_subnet_ids = local.vpc_outputs.private_subnet_ids
  vpc_id             = local.vpc_outputs.vpc_id

  primary_iam_roles = [for role in var.primary_iam_roles : {
    rolearn  = local.primary_role_map[role.role]
    username = format("identity-%s", role.role)
    groups   = role.groups
  }]

  delegated_iam_roles = [for role in var.delegated_iam_roles : {
    rolearn  = local.delegated_role_map[role.role]
    username = format("%s-%s", module.this.stage, role.role)
    groups   = role.groups
  }]

  map_additional_iam_roles = concat(local.primary_iam_roles, local.delegated_iam_roles)
}

module "eks_cluster" {
  source = "git::https://github.com/cloudposse/terraform-aws-eks-cluster.git?ref=tags/0.29.0"

  region     = var.region
  attributes = local.attributes

  allowed_security_groups      = var.allowed_security_groups
  allowed_cidr_blocks          = var.allowed_cidr_blocks
  apply_config_map_aws_auth    = var.apply_config_map_aws_auth
  cluster_log_retention_period = var.cluster_log_retention_period
  enabled_cluster_log_types    = var.enabled_cluster_log_types
  endpoint_private_access      = var.cluster_endpoint_private_access
  endpoint_public_access       = var.cluster_endpoint_public_access
  kubernetes_version           = var.cluster_kubernetes_version
  oidc_provider_enabled        = var.oidc_provider_enabled
  map_additional_aws_accounts  = var.map_additional_aws_accounts
  map_additional_iam_roles     = local.map_additional_iam_roles
  map_additional_iam_users     = var.map_additional_iam_users
  public_access_cidrs          = var.public_access_cidrs
  subnet_ids                   = concat(local.private_subnet_ids, local.public_subnet_ids)
  vpc_id                       = local.vpc_id

  kubernetes_config_map_ignore_role_changes = false

  # Managed Node Groups do not expose nor accept any Security Groups.
  # Instead, EKS creates a Security Group and applies it to ENI that is attached to EKS Control Plane master nodes and to any managed workloads.
  #workers_security_group_ids = compact([local.vpn_allowed_cidr_sg])

  # Ensure ordering of resource creation:
  # 1. Create the EKS cluster
  # 2. Create any resources OTHER THAN MANAGED NODE GROUPS that need to be added to the
  #    Kubernetes `aws-auth` configMap by our Terraform
  # 3. Use Terraform to create the Kubernetes `aws-auth` configMap we need
  # 4. Create managed node groups. AWS EKS will automatically add newly created
  #    managed node groups to the Kubernetes `aws-auth` configMap.
  #
  # We must execute steps in this order because:
  # - 1 before 3 because we cannot add a configMap to a cluster that does not exist
  # - 2 before 3 because Terraform will not create and update the configMap in separate steps, so it must have
  #   all the data to add before it creates the configMap
  # - 3 before 4 because EKS will create the Kubernetes `aws-auth` configMap if it does not exist
  #   when it creates the first managed node group, and Terraform will not modify a resource it did not create
  #
  # We count on the EKS cluster module to ensure steps 1-3 are done in the right order.
  # We then depend on the kubernetes_config_map_id, using the `module_depends_on` feature of the node-group module,
  # to ensure we do not proceed to step 4 until after step 3 is completed.

  # workers_role_arns is part of the data that needs to be collected/created in step 2 above
  # because it goes into the `aws-auth` configMap created in step 3. However, because of the
  # ordering requirements, we cannot wait for new managed node groups to be created. Fortunately,
  # this is not necessary, because AWS EKS will automatically add node groups to the `aws-auth` configMap
  # when they are created. However, after they are created, they will not be replaced if they are
  # later removed, and in step 3 we replace the entire configMap. So we have to add the pre-existing
  # managed node groups here, and we get that by reading our current (pre plan or apply) Terraform state.
  workers_role_arns = compact(concat(local.eks_outputs.eks_managed_node_workers_role_arns))

  context = module.this.context
}

locals {
  node_group_default_availability_zones = var.node_group_defaults.availability_zones == null ? var.region_availability_zones : var.node_group_defaults.availability_zones
  node_group_default_kubernetes_version = var.node_group_defaults.kubernetes_version == null ? var.cluster_kubernetes_version : var.node_group_defaults.kubernetes_version

  # values(module.region_node_group) is an array of `region_node_group` objects
  # values(module.region_node_group)[*].region_node_groups is an array of
  #   maps with keys availability zones and values the output map of terraform-aws-eks-node-group
  # node_groups is a flattened array of output maps of terraform-aws-eks-node-group
  node_groups = flatten([for m in values(module.region_node_group)[*].region_node_groups : values(m)])

  # node_group_arns is a list of all the node group ARNs in the cluster
  node_group_arns      = compact([for group in local.node_groups : group.eks_node_group_arn])
  node_group_role_arns = compact([for group in local.node_groups : group.eks_node_group_role_arn])
}

module "region_node_group" {
  for_each = module.this.enabled ? var.node_groups : {}

  source = "./modules/node_group_by_region"

  availability_zones = each.value.availability_zones == null ? local.node_group_default_availability_zones : each.value.availability_zones
  attributes         = flatten(concat(var.attributes, [each.key], [var.color], each.value.attributes == null ? var.node_group_defaults.attributes : each.value.attributes))

  node_group_size = module.this.enabled ? {
    desired_size = each.value.desired_group_size == null ? var.node_group_defaults.desired_group_size : each.value.desired_group_size
    min_size     = each.value.min_group_size == null ? var.node_group_defaults.min_group_size : each.value.min_group_size
    max_size     = each.value.max_group_size == null ? var.node_group_defaults.max_group_size : each.value.max_group_size
  } : null

  cluster_context = module.this.enabled ? {
    cluster_name              = module.eks_cluster.eks_cluster_id
    create_before_destroy     = each.value.create_before_destroy == null ? var.node_group_defaults.create_before_destroy : each.value.create_before_destroy
    disk_size                 = each.value.disk_size == null ? var.node_group_defaults.disk_size : each.value.disk_size
    enable_cluster_autoscaler = each.value.enable_cluster_autoscaler == null ? var.node_group_defaults.enable_cluster_autoscaler : each.value.enable_cluster_autoscaler
    instance_types            = each.value.instance_types == null ? var.node_group_defaults.instance_types : each.value.instance_types
    ami_type                  = each.value.ami_type == null ? var.node_group_defaults.ami_type : each.value.ami_type
    ami_release_version       = each.value.ami_release_version == null ? var.node_group_defaults.ami_release_version : each.value.ami_release_version
    kubernetes_version        = each.value.kubernetes_version == null ? local.node_group_default_kubernetes_version : each.value.kubernetes_version
    kubernetes_labels         = each.value.kubernetes_labels == null ? var.node_group_defaults.kubernetes_labels : each.value.kubernetes_labels
    kubernetes_taints         = each.value.kubernetes_taints == null ? var.node_group_defaults.kubernetes_taints : each.value.kubernetes_taints
    resources_to_tag          = each.value.resources_to_tag == null ? var.node_group_defaults.resources_to_tag : each.value.resources_to_tag
    subnet_type_tag_key       = var.subnet_type_tag_key
    vpc_id                    = local.vpc_id

    # See "Ensure ordering of resource creation" comment above for explanation
    # of "module_depends_on"
    module_depends_on = module.eks_cluster.kubernetes_config_map_id
  } : null

  context = module.this.context
}
