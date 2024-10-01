provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account_id
}

data "aws_region" "current" {
}

locals {
  cluster_name = "${data.aws_region.current.name}.${var.zone_name}"
}

module "kops_metadata_networking" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-network.git?ref=tags/0.2.0"
  enabled      = var.enabled
  cluster_name = local.cluster_name
}

module "kops_metadata_instance_groups" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-launch-configurations.git?ref=tags/0.1.0"
  enabled      = var.enabled
  cluster_name = local.cluster_name
}

locals {
  default_instance_group_enabled   = var.enabled && length(module.kops_metadata_instance_groups.nodes) > 0 ? 1 : 0
  additional_instance_groups_count = var.enabled && length(module.kops_metadata_instance_groups.nodes) > 1 ? length(module.kops_metadata_instance_groups.nodes) - 1 : 0
}

data "aws_autoscaling_group" "default" {
  count = local.default_instance_group_enabled
  name  = module.kops_metadata_instance_groups.nodes[0]
}

data "aws_autoscaling_group" "additional" {
  count = local.additional_instance_groups_count
  name  = module.kops_metadata_instance_groups.nodes[count.index + 1]
}

data "aws_launch_configuration" "default" {
  count = local.default_instance_group_enabled
  name  = data.aws_autoscaling_group.default[count.index].launch_configuration
}

data "aws_launch_configuration" "additional" {
  count = local.additional_instance_groups_count
  name  = data.aws_autoscaling_group.additional[count.index].launch_configuration
}

data "aws_subnet" "default" {
  count = var.enabled ? length(module.kops_metadata_networking.private_subnet_ids) : 0
  id    = module.kops_metadata_networking.private_subnet_ids[count.index]
}

locals {
  nodes_availability_zones = distinct(flatten(concat(data.aws_autoscaling_group.default.*.availability_zones, data.aws_autoscaling_group.additional.*.availability_zones)))
}

resource "spotinst_ocean_aws" "default" {
  count = local.default_instance_group_enabled

  name          = local.cluster_name
  controller_id = local.cluster_name
  region        = data.aws_region.current.name

  max_size = var.max_size
  min_size = var.min_size

  subnet_ids = [for subnet in data.aws_subnet.default : subnet.id if contains(local.nodes_availability_zones, subnet.availability_zone)]
  whitelist  = var.instance_types

  image_id             = data.aws_launch_configuration.default[0].image_id
  user_data            = data.aws_launch_configuration.default[0].user_data
  iam_instance_profile = data.aws_launch_configuration.default[0].iam_instance_profile

  security_groups = [module.kops_metadata_networking.nodes_security_group_id]
  key_name        = data.aws_launch_configuration.default[0].key_name


  associate_public_ip_address = data.aws_launch_configuration.default[0].associate_public_ip_address
  root_volume_size            = data.aws_launch_configuration.default[0].root_block_device[0].volume_size
  monitoring                  = data.aws_launch_configuration.default[0].enable_monitoring

  ebs_optimized = data.aws_launch_configuration.default[0].ebs_optimized

  spot_percentage            = var.spot_percentage
  utilize_reserved_instances = var.utilize_reserved_instances
  draining_timeout           = var.draining_timeout
  fallback_to_ondemand       = var.fallback_to_ondemand

  autoscaler {
    autoscale_is_enabled     = var.autoscale_enabled
    autoscale_is_auto_config = var.autoscale_is_auto_config
    autoscale_cooldown       = var.autoscale_cooldown

    dynamic "autoscale_headroom" {
      for_each = toset(compact(list(var.autoscale_is_auto_config ? "" : "autoscale_headroom_enabled")))
      content {
        cpu_per_unit    = var.autoscale_headroom_cpu_per_unit
        gpu_per_unit    = var.autoscale_headroom_gpu_per_unit
        memory_per_unit = var.autoscale_headroom_memory_per_unit
        num_of_units    = var.autoscale_headroom_num_of_units
      }
    }

    autoscale_down {
      evaluation_periods = var.autoscale_down_num_of_units
    }

    resource_limits {
      max_vcpu       = var.autoscale_resource_max_vcpu
      max_memory_gib = var.autoscale_resource_memory_gib
    }
  }

  dynamic "tags" {
    for_each = toset(
      concat(
        [
          { key = "Name", value = join("", data.aws_autoscaling_group.default.*.name) }
        ],
        module.kops_metadata_instance_groups.nodes_tags,
        module.kops_metadata_instance_groups.common_tags
      )
    )
    content {
      key   = tags.value["key"]
      value = tags.value["value"]
    }
  }

  update_policy {
    should_roll = var.should_roll

    roll_config {
      batch_size_percentage = var.roll_batch_size_percentage
    }
  }
}

resource "spotinst_ocean_aws_launch_spec" "default" {
  count = local.additional_instance_groups_count

  ocean_id = join("", spotinst_ocean_aws.default.*.id)

  image_id             = data.aws_launch_configuration.additional[count.index].image_id
  user_data            = data.aws_launch_configuration.additional[count.index].user_data
  iam_instance_profile = data.aws_launch_configuration.additional[count.index].iam_instance_profile
}
