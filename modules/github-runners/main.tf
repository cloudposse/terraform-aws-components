locals {
  enabled                = module.this.enabled
  vpc_id                 = module.vpc.outputs.vpc_id
  vpc_private_subnet_ids = module.vpc.outputs.private_subnet_ids
  identity_account_name  = module.account_map.outputs.identity_account_account_name
  identity_account_id    = module.account_map.outputs.full_account_map[local.identity_account_name]

  userdata_template                 = "${path.module}/templates/user-data.sh"
  create-latest-svc                 = "${path.module}/templates/create-latest-svc.sh"
  deregister_runner_script_template = "${path.module}/templates/deregister-github-runner"

  cloud_config = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/usr/local/bin/deregister-github-runner"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content = base64encode(templatefile(local.deregister_runner_script_template, {
        github_scope          = var.github_scope,
        github_token_ssm_path = join("", data.aws_ssm_parameter.github_token.*.name),
        runner_version        = var.runner_version
      }))
    },
    {
      path        = "/tmp/amazon-cloudwatch-agent.json"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/templates/amazon-cloudwatch-agent.json")
    },
    {
      path        = "/tmp/create-latest-svc.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64(local.create-latest-svc)
    },
  ]
})}
  END
}

data "aws_ssm_parameter" "github_token" {
  count = local.enabled ? 1 : 0

  name            = format(var.ssm_parameter_name_format, var.ssm_path, var.ssm_path_key)
  with_decryption = true
}

data "cloudinit_config" "config" {
  count = local.enabled ? 1 : 0

  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content      = local.cloud_config
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "user-data.sh"
    content = templatefile(local.userdata_template, {
      docker_compose_version = var.docker_compose_version
      github_token_ssm_path  = join("", data.aws_ssm_parameter.github_token.*.name)
      github_scope           = var.github_scope
      labels                 = join(",", var.runner_labels)
      pre_install            = var.userdata_pre_install
      post_install           = var.userdata_post_install
      runner_version         = var.runner_version
      runner_group           = var.runner_group
    })
  }
}

data "aws_ami" "runner" {
  count = local.enabled ? 1 : 0

  most_recent = "true"

  dynamic "filter" {
    for_each = var.ami_filter
    content {
      name   = filter.key
      values = filter.value
    }
  }

  owners = var.ami_owners
}

module "sg" {
  source  = "cloudposse/security-group/aws"
  version = "1.0.1"

  security_group_description = "Security group for GitHub runner"
  allow_all_egress           = true
  vpc_id                     = local.vpc_id

  context = module.this.context
}

module "autoscale_group" {
  source  = "cloudposse/ec2-autoscale-group/aws"
  version = "0.35.1"

  image_id                    = join("", data.aws_ami.runner.*.id)
  instance_type               = var.instance_type
  mixed_instances_policy      = var.mixed_instances_policy
  subnet_ids                  = local.vpc_private_subnet_ids
  health_check_type           = "EC2"
  min_size                    = var.min_size
  max_size                    = var.max_size
  default_cooldown            = var.default_cooldown
  scale_down_cooldown_seconds = var.scale_down_cooldown_seconds
  wait_for_capacity_timeout   = var.wait_for_capacity_timeout
  user_data_base64            = join("", data.cloudinit_config.config.*.rendered)
  tags                        = module.this.tags
  security_group_ids          = [module.sg.id]
  iam_instance_profile_name   = join("", aws_iam_instance_profile.github_action_runner.*.name)
  block_device_mappings       = var.block_device_mappings
  associate_public_ip_address = false
  max_instance_lifetime       = var.max_instance_lifetime

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled            = true
  cpu_utilization_high_threshold_percent  = var.cpu_utilization_high_threshold_percent
  cpu_utilization_high_period_seconds     = var.cpu_utilization_high_period_seconds
  cpu_utilization_high_evaluation_periods = var.cpu_utilization_high_evaluation_periods
  cpu_utilization_low_threshold_percent   = var.cpu_utilization_low_threshold_percent
  cpu_utilization_low_period_seconds      = var.cpu_utilization_low_period_seconds
  cpu_utilization_low_evaluation_periods  = var.cpu_utilization_low_evaluation_periods

  context = module.this.context
}

module "graceful_scale_in" {
  source = "./modules/graceful_scale_in"

  autoscaling_group_name = module.autoscale_group.autoscaling_group_name
  command                = "deregister-github-runner"

  attributes = ["deregistration"]

  context = module.this.context
}
