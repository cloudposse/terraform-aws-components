locals {
  enabled                = module.this.enabled
  vpc_id                 = module.vpc.outputs.vpc_id
  vpc_private_subnet_ids = module.vpc.outputs.private_subnet_ids
  identity_account_id    = module.account_map.outputs.full_account_map["identity"]

  userdata_template = "${path.module}/templates/user-data.sh"

  cloudwatch_agent_config = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/tmp/amazon-cloudwatch-agent.json"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/templates/amazon-cloudwatch-agent.json")
    },
  ]
})}
  END
}

data "cloudinit_config" "config" {
  count = local.enabled ? 1 : 0

  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content      = local.cloudwatch_agent_config
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "user-data.sh"
    content = templatefile(local.userdata_template, {
      github_token   = data.aws_ssm_parameter.github_token[0].value
      github_scope   = var.github_scope
      runner_version = var.runner_version
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
  version = "0.3.1"

  description = "Security group for GitHub runner"
  rules = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  vpc_id = local.vpc_id

  context = module.this.context
}

module "autoscale_group" {
  source  = "cloudposse/ec2-autoscale-group/aws"
  version = "0.14.0"

  image_id                    = data.aws_ami.runner[0].id
  instance_type               = var.instance_type
  mixed_instances_policy      = var.mixed_instances_policy
  subnet_ids                  = local.vpc_private_subnet_ids
  health_check_type           = "EC2"
  min_size                    = var.min_size
  max_size                    = var.max_size
  default_cooldown            = var.default_cooldown
  scale_down_cooldown_seconds = var.scale_down_cooldown_seconds
  wait_for_capacity_timeout   = var.wait_for_capacity_timeout
  user_data_base64            = data.cloudinit_config.config[0].rendered
  tags                        = module.this.tags
  security_group_ids          = [module.sg.id]
  iam_instance_profile_name   = aws_iam_instance_profile.github-action-runner[0].name
  block_device_mappings       = var.block_device_mappings
  associate_public_ip_address = false

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent

  context = module.this.context
}
