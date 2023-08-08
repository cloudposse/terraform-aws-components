locals {
  enabled     = module.this.enabled
  eks_outputs = module.eks.outputs
  vpc_outputs = module.vpc.outputs

  attributes = flatten(concat(module.this.attributes, [var.color]))

  this_account_name     = module.iam_roles.current_account_account_name
  identity_account_name = module.iam_roles.identity_account_account_name

  role_map = { (local.this_account_name) = var.aws_team_roles_rbac[*].aws_team_role }

  aws_team_roles_auth = [for role in var.aws_team_roles_rbac : {
    rolearn  = module.iam_arns.principals_map[local.this_account_name][role.aws_team_role]
    username = format("%s-%s", local.this_account_name, role.aws_team_role)
    groups   = role.groups
  }]

  # Existing Fargate Profile role ARNs
  fargate_profile_role_arns = local.eks_outputs.fargate_profile_role_arns

  map_fargate_profile_roles = [
    for role_arn in local.fargate_profile_role_arns : {
      rolearn : role_arn
      username : "system:node:{{SessionName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        # `system:node-proxier` is required by Fargate (and it's added automatically to the `aws-auth` ConfigMap when a Fargate Profile gets created, so we need to add it back)
        # Allows access to the resources required by the `kube-proxy` component
        # https://kubernetes.io/docs/reference/access-authn-authz/rbac/
        "system:node-proxier"
      ]
    }
  ]

  map_additional_iam_roles = concat(
    local.aws_team_roles_auth,
    local.aws_sso_iam_roles_auth,
    var.map_additional_iam_roles,
    local.map_fargate_profile_roles,
  )

  # Existing managed worker role ARNs
  managed_worker_role_arns = local.eks_outputs.eks_managed_node_workers_role_arns

  # If Karpenter IAM role is enabled, add it to the `aws-auth` ConfigMap to allow the nodes launched by Karpenter to join the EKS cluster
  karpenter_role_arn = one(aws_iam_role.karpenter[*].arn)

  worker_role_arns = compact(concat(
    var.map_additional_worker_roles,
    local.managed_worker_role_arns,
    [local.karpenter_role_arn]
  ))

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
  for v in local.availability_zone_ids_expanded : local.az_id_map[v]] : local.availability_zones_expanded

  # Get only the public subnets that correspond to the AZs provided in `var.availability_zones`
  # `az_public_subnets_map` is a map of AZ names to list of public subnet IDs in the AZs
  # LEGACY PATCH: for legacy VPC with no az_public_subnets_map
  # public_subnet_ids = flatten([for k, v in local.vpc_outputs.az_public_subnets_map : v if contains(var.availability_zones, k) || length(var.availability_zones) == 0])
  public_subnet_ids = try(flatten([for k, v in local.vpc_outputs.az_public_subnets_map : v if contains(var.availability_zones, k) || length(var.availability_zones) == 0]),
  local.vpc_outputs.public_subnet_ids)

  # Get only the private subnets that correspond to the AZs provided in `var.availability_zones`
  # `az_private_subnets_map` is a map of AZ names to list of private subnet IDs in the AZs
  # LEGACY PATCH: for legacy VPC with no az_public_subnets_map
  # private_subnet_ids = flatten([for k, v in local.vpc_outputs.az_private_subnets_map : v if contains(var.availability_zones, k) || length(var.availability_zones) == 0])
  private_subnet_ids = try(flatten([for k, v in local.vpc_outputs.az_private_subnets_map : v if contains(var.availability_zones, k) || length(var.availability_zones) == 0]),
  local.vpc_outputs.private_subnet_ids)

  # Infer the availability zones from the private subnets if var.availability_zones is empty:
  availability_zones = length(local.availability_zones_normalized) == 0 ? keys(local.vpc_outputs.az_private_subnets_map) : local.availability_zones_normalized
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
  version = "2.9.0"

  region     = var.region
  attributes = local.attributes

  kube_data_auth_enabled = false
  # exec_auth is more reliable than data_auth when the aws CLI is available
  # Details at https://github.com/cloudposse/terraform-aws-eks-cluster/releases/tag/0.42.0
  kube_exec_auth_enabled = !var.kubeconfig_file_enabled
  # If using `exec` method (recommended) for authentication, provide an explicit
  # IAM role ARN to exec as for authentication to EKS cluster.
  kube_exec_auth_role_arn         = coalesce(var.kube_exec_auth_role_arn, module.iam_roles.terraform_role_arn)
  kube_exec_auth_role_arn_enabled = true
  # Path to KUBECONFIG file to use to access the EKS cluster
  kubeconfig_path         = var.kubeconfig_file
  kubeconfig_path_enabled = var.kubeconfig_file_enabled

  allowed_security_groups      = var.allowed_security_groups
  allowed_cidr_blocks          = local.allowed_cidr_blocks
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
  subnet_ids                   = var.cluster_private_subnets_only ? local.private_subnet_ids : concat(local.private_subnet_ids, local.public_subnet_ids)
  vpc_id                       = local.vpc_id

  kubernetes_config_map_ignore_role_changes = false

  # EKS addons
  addons = local.addons

  addons_depends_on = var.addons_depends_on ? concat(
    [module.region_node_group], local.addons_depends_on,
    values(local.final_addon_service_account_role_arn_map)
  ) : null

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
  workers_role_arns = local.worker_role_arns

  aws_auth_yaml_strip_quotes = var.aws_auth_yaml_strip_quotes

  cluster_encryption_config_enabled                         = var.cluster_encryption_config_enabled
  cluster_encryption_config_kms_key_id                      = var.cluster_encryption_config_kms_key_id
  cluster_encryption_config_kms_key_enable_key_rotation     = var.cluster_encryption_config_kms_key_enable_key_rotation
  cluster_encryption_config_kms_key_deletion_window_in_days = var.cluster_encryption_config_kms_key_deletion_window_in_days
  cluster_encryption_config_kms_key_policy                  = var.cluster_encryption_config_kms_key_policy
  cluster_encryption_config_resources                       = var.cluster_encryption_config_resources

  context = module.this.context
}
