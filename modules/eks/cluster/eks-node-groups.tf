locals {
  node_groups_enabled = local.enabled && var.managed_node_groups_enabled

  node_group_default_availability_zones = var.node_group_defaults.availability_zones == null ? local.availability_zones : var.node_group_defaults.availability_zones
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
  for_each = local.node_groups_enabled ? var.node_groups : {}

  source = "./modules/node_group_by_region"

  availability_zones = each.value.availability_zones == null ? local.node_group_default_availability_zones : each.value.availability_zones
  attributes = flatten(concat(var.attributes, [each.key], [
    var.color
  ], each.value.attributes == null ? var.node_group_defaults.attributes : each.value.attributes))

  node_group_size = module.this.enabled ? {
    desired_size = each.value.desired_group_size == null ? var.node_group_defaults.desired_group_size : each.value.desired_group_size
    min_size = each.value.min_group_size == null ? (
      var.node_group_defaults.min_group_size == null ? (
        length(each.value.availability_zones == null ? local.node_group_default_availability_zones : each.value.availability_zones)
      ) : var.node_group_defaults.min_group_size
    ) : each.value.min_group_size
    max_size = each.value.max_group_size == null ? var.node_group_defaults.max_group_size : each.value.max_group_size
  } : null

  cluster_context = module.this.enabled ? {
    ami_release_version        = each.value.ami_release_version == null ? var.node_group_defaults.ami_release_version : each.value.ami_release_version
    ami_type                   = each.value.ami_type == null ? var.node_group_defaults.ami_type : each.value.ami_type
    az_abbreviation_type       = var.availability_zone_abbreviation_type
    cluster_autoscaler_enabled = each.value.cluster_autoscaler_enabled == null ? var.node_group_defaults.cluster_autoscaler_enabled : each.value.cluster_autoscaler_enabled
    cluster_name               = local.eks_cluster_id
    create_before_destroy      = each.value.create_before_destroy == null ? var.node_group_defaults.create_before_destroy : each.value.create_before_destroy
    instance_types             = each.value.instance_types == null ? var.node_group_defaults.instance_types : each.value.instance_types
    kubernetes_labels          = each.value.kubernetes_labels == null ? var.node_group_defaults.kubernetes_labels : each.value.kubernetes_labels
    kubernetes_taints          = each.value.kubernetes_taints == null ? var.node_group_defaults.kubernetes_taints : each.value.kubernetes_taints
    node_userdata              = each.value.node_userdata == null ? var.node_group_defaults.node_userdata : each.value.node_userdata
    kubernetes_version         = each.value.kubernetes_version == null ? local.node_group_default_kubernetes_version : each.value.kubernetes_version
    resources_to_tag           = each.value.resources_to_tag == null ? var.node_group_defaults.resources_to_tag : each.value.resources_to_tag
    subnet_type_tag_key        = local.subnet_type_tag_key
    aws_ssm_agent_enabled      = var.aws_ssm_agent_enabled
    vpc_id                     = local.vpc_id

    block_device_map = lookup(local.legacy_converted_block_device_map, each.key, local.block_device_map_w_defaults[each.key])
  } : null

  context = module.this.context
}

## Warn if you are using camelCase in the `block_device_map` argument.
## Without this warning, camelCase inputs will be silently ignored and replaced with defaults,
## which is very hard to notice and debug.
#
## We just need some kind of data source or resource to trigger the warning.
## Because we need it to run for each node group, there are no good options
## among actually useful data sources or resources. We also have to ensure
## that Terraform updates it when the `block_device_map` argument changes,
## and does not skip the checks because it can use the cached value.
resource "random_pet" "camel_case_warning" {
  for_each = local.node_groups_enabled ? var.node_groups : {}

  keepers = {
    hash = base64sha256(jsonencode(local.block_device_map_w_defaults[each.key]))
  }

  lifecycle {
    precondition {
      condition = length(compact(flatten([for device_name, device_map in local.block_device_map_w_defaults[each.key] : [
        lookup(device_map.ebs, "volumeSize", null),
        lookup(device_map.ebs, "volumeType", null),
        lookup(device_map.ebs, "kmsKeyId", null),
        lookup(device_map.ebs, "deleteOnTermination", null),
        lookup(device_map.ebs, "snapshotId", null),
        ]
      ]))) == 0
      error_message = <<-EOT
        The `block_device_map` argument in the `node_groups[${each.key}]` module
        does not support the `volumeSize`, `volumeType`, `kmsKeyId`, `deleteOnTermination`, or `snapshotId` arguments.
        Please use `volume_size`, `volume_type`, `kms_key_id`, `delete_on_termination`, and `snapshot_id` instead."
        EOT
    }
  }
}

# DEPRECATION SUPPORT
# `disk_size` and `disk_encryption_enabled are deprecated in favor of `block_device_map`.
# Convert legacy use to new format.

locals {
  legacy_disk_inputs = {
    for k, v in(local.node_groups_enabled ? var.node_groups : {}) : k => {
      disk_encryption_enabled = v.disk_encryption_enabled == null ? var.node_group_defaults.disk_encryption_enabled : v.disk_encryption_enabled
      disk_size               = v.disk_size == null ? var.node_group_defaults.disk_size : v.disk_size
      } if(
      ((v.disk_encryption_enabled == null ? var.node_group_defaults.disk_encryption_enabled : v.disk_encryption_enabled) != null)
      || ((v.disk_size == null ? var.node_group_defaults.disk_size : v.disk_size) != null)
    )
  }

  legacy_converted_block_device_map = {
    for k, v in local.legacy_disk_inputs : k => {
      "/dev/xvda" = {
        no_device    = null
        virtual_name = null
        ebs = {
          delete_on_termination = true
          encrypted             = v.disk_encryption_enabled
          iops                  = null
          kms_key_id            = null
          snapshot_id           = null
          throughput            = null
          volume_size           = v.disk_size
          volume_type           = "gp2"
        } # ebs
      }   # "/dev/xvda"
    }     # k => { "/dev/xvda" = { ... } }
  }

  block_device_map_w_defaults = {
    for k, v in(local.node_groups_enabled ? var.node_groups : {}) : k =>
    v.block_device_map == null ? var.node_group_defaults.block_device_map : v.block_device_map
  }

}
