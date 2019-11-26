provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account_id
}

module "account_id" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-chamber-reader.git?ref=init"

  enabled         = var.enabled
  chamber_format  = var.chamber_format
  chamber_service = var.chamber_service
  parameter       = var.chamber_name_account_id
  override_value  = var.override_account_id
}

module "token" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-chamber-reader.git?ref=init"

  enabled         = var.enabled
  chamber_format  = var.chamber_format
  chamber_service = var.chamber_service
  parameter       = var.chamber_name_token
  override_value  = var.override_token
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

module "kops_metadata_launch_configurations" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-launch-configurations.git?ref=init"
  enabled      = var.enabled
  cluster_name = local.cluster_name
}

locals {
  node_launch_configurations            = values(module.kops_metadata_launch_configurations.nodes)
  default_launch_configuration          = element(local.node_launch_configurations, 0)
  additional_launch_configuration_count = length(local.node_launch_configurations) - 1
  additional_launch_configuration       = slice(local.node_launch_configurations, local.additional_launch_configuration_count > 0 ? 1 : 0, local.additional_launch_configuration_count)
}

resource "spotinst_ocean_aws" "default" {
  count = var.enabled ? 1 : 0

  name          = local.cluster_name
  controller_id = local.cluster_name
  region        = data.aws_region.current.name

  max_size = var.max_size
  min_size = var.min_size

  subnet_ids = module.kops_metadata_networking.private_subnet_ids
  whitelist  = var.instance_types

  image_id             = local.default_launch_configuration.image_id
  user_data            = local.default_launch_configuration.user_data
  iam_instance_profile = local.default_launch_configuration.iam_instance_profile

  security_groups = [module.kops_metadata_networking.nodes_security_group_id]
  key_name        = local.default_launch_configuration.key_name


  associate_public_ip_address = local.default_launch_configuration.associate_public_ip_address
  root_volume_size            = local.default_launch_configuration.root_block_device[0].volume_size
  monitoring                  = local.default_launch_configuration.enable_monitoring

  ebs_optimized = local.default_launch_configuration.ebs_optimized

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
      max_vcpu       = var.autoscale_resource_max_vpcu
      max_memory_gib = var.autoscale_resource_memory_gib
    }
  }

  dynamic "tags" {
    for_each = toset(local.default_launch_configuration.tags)
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
  count = var.enabled ? length(local.additional_launch_configuration) : 0

  ocean_id = join("", spotinst_ocean_aws.default.*.id)

  image_id             = local.additional_launch_configuration[count.index].image_id
  user_data            = local.additional_launch_configuration[count.index].user_data
  iam_instance_profile = local.additional_launch_configuration[count.index].iam_instance_profile
}
