locals {
  enabled                = module.this.enabled
  vpc_id                 = module.vpc.outputs.vpc_id
  vpc_private_subnet_ids = module.vpc.outputs.private_subnet_ids
  identity_account_name  = module.account_map.outputs.identity_account_account_name
  identity_account_id    = module.account_map.outputs.full_account_map[local.identity_account_name]
  ecr_repo_arn           = module.ecr.outputs.ecr_repo_arn_map[var.ecr_repo_name]
  ecr_repo_url           = module.ecr.outputs.ecr_repo_url_map[var.ecr_repo_name]
  ecr_account_id         = element(split(".", local.ecr_repo_url), 0)
  ecr_region             = coalesce(var.ecr_region, var.region)
  spacelift_runner_image = coalesce(var.spacelift_runner_image, local.ecr_repo_url)
  userdata_template      = "${path.module}/templates/user-data.sh"
  spacelift_service_file = "${path.module}/templates/spacelift@.service"

  spacelift_service_config = <<-END
    #cloud-config
    ${jsonencode({
  write_files = flatten([
    {
      path        = "/etc/systemd/system/spacelift@.service"
      permissions = "0655"
      owner       = "root:root"
      content     = file(local.spacelift_service_file)
    }
    ]
  )
})}
END
}

resource "spacelift_worker_pool" "primary" {
  count = local.enabled ? 1 : 0

  name        = module.this.id
  description = "Deployed to ${var.region} within '${join("-", compact([module.this.tenant, module.this.stage]))}' AWS account"
}

data "cloudinit_config" "config" {
  count = local.enabled ? 1 : 0

  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename     = "spacelift@.service"
    content      = local.spacelift_service_config
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "user-data.sh"
    content = templatefile(local.userdata_template, {
      region                            = var.region
      aws_config_file                   = var.aws_config_file
      aws_profile                       = coalesce(var.aws_profile, "${var.namespace}-identity")
      ecr_region                        = local.ecr_region
      ecr_account_id                    = local.ecr_account_id
      spacelift_runner_image            = local.spacelift_runner_image
      spacelift_worker_pool_private_key = join("", spacelift_worker_pool.primary.*.private_key)
      spacelift_worker_pool_config      = join("", spacelift_worker_pool.primary.*.config)
      spacelift_domain_name             = var.spacelift_domain_name
      github_netrc_enabled              = var.github_netrc_enabled
      github_netrc_ssm_path_token       = var.github_netrc_ssm_path_token
      github_netrc_ssm_path_user        = var.github_netrc_ssm_path_user
      spacelift_agents_per_node         = var.spacelift_agents_per_node
      infracost_enabled                 = var.infracost_enabled
      infracost_api_token_ssm_path      = var.infracost_api_token_ssm_path
      infracost_warn_on_failure         = var.infracost_warn_on_failure
      infracost_cli_args                = var.infracost_cli_args
    })
  }
}

module "security_group" {
  source  = "cloudposse/security-group/aws"
  version = "2.0.0-rc1"

  security_group_description = "Security Group for Spacelift worker pool"
  allow_all_egress           = true

  vpc_id = local.vpc_id

  context = module.this.context
}

module "autoscale_group" {
  source  = "cloudposse/ec2-autoscale-group/aws"
  version = "0.34.1"

  image_id                    = var.spacelift_ami_id == null ? join("", data.aws_ami.spacelift.*.image_id) : var.spacelift_ami_id
  instance_type               = var.instance_type
  mixed_instances_policy      = var.mixed_instances_policy
  subnet_ids                  = local.vpc_private_subnet_ids
  health_check_type           = var.health_check_type
  health_check_grace_period   = var.health_check_grace_period
  user_data_base64            = join("", data.cloudinit_config.config.*.rendered)
  associate_public_ip_address = false
  block_device_mappings       = var.block_device_mappings
  iam_instance_profile_name   = join("", aws_iam_instance_profile.default.*.name)
  security_group_ids          = [module.security_group.id]
  termination_policies        = var.termination_policies
  wait_for_capacity_timeout   = var.wait_for_capacity_timeout
  ebs_optimized               = var.ebs_optimized

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  default_cooldown                       = var.default_cooldown
  scale_down_cooldown_seconds            = var.scale_down_cooldown_seconds
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent

  # The instance refresh definition
  # If this block is configured, an Instance Refresh will be started when the Auto Scaling Group is updated
  instance_refresh = var.instance_refresh

  context = module.this.context
}
