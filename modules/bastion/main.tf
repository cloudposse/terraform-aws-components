locals {
  enabled     = module.this.enabled
  vpc_id      = module.vpc.outputs.vpc_id
  vpc_outputs = module.vpc.outputs

  # Get only the subnets that correspond to the AZs provided in `var.availability_zones` if set.
  # `az_private_subnets_map` and `az_public_subnets_map` are a map of AZ names to list of subnet IDs in the AZs
  vpc_private_subnet_ids = length(var.availability_zones) == 0 ? module.vpc.outputs.private_subnet_ids : flatten([for k, v in local.vpc_outputs.az_private_subnets_map : v if contains(var.availability_zones, k)])
  vpc_public_subnet_ids  = length(var.availability_zones) == 0 ? module.vpc.outputs.public_subnet_ids : flatten([for k, v in local.vpc_outputs.az_public_subnets_map : v if contains(var.availability_zones, k)])
  vpc_subnet_ids         = var.associate_public_ip_address ? local.vpc_public_subnet_ids : local.vpc_private_subnet_ids

  userdata_template             = "${path.module}/templates/user-data.sh"
  container_template            = "${path.module}/templates/container.sh"
  container_cloud_init_template = "${path.module}/templates/container-cloud-init.sh"

  cloudwatch_agent_config = templatefile(local.container_cloud_init_template, {
    content = jsonencode({
      write_files = [
        {
          path        = "/tmp/container.sh"
          permissions = "0755"
          owner       = "root:root"
          encoding    = "b64"
          content = base64encode(templatefile(local.container_template, {
            region            = var.region
            image_repository  = var.image_repository
            image_container   = var.image_container
            container_command = var.container_command
          }))
        },
      ]
    })
  })
}

module "sg" {
  source  = "cloudposse/security-group/aws"
  version = "2.2.0"

  rules  = var.security_group_rules
  vpc_id = local.vpc_id

  context = module.this.context
}

module "ssm_tls_ssh_key_pair" {
  source  = "cloudposse/ssm-tls-ssh-key-pair/aws"
  version = "0.10.2"

  ssm_path_prefix   = format("%s/%s", "bastion", "ssh_private_key")
  ssh_key_algorithm = "RSA"

  kms_key_id = var.kms_alias_name_ssm

  context = module.this.context
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
    content      = file(local.userdata_template)
  }
}

data "aws_ami" "bastion_image" {
  count = local.enabled ? 1 : 0

  most_recent = "true"

  dynamic "filter" {
    for_each = {
      name = ["amzn2-ami-hvm-2.*-x86_64-ebs"]
    }
    content {
      name   = filter.key
      values = filter.value
    }
  }

  owners = ["amazon"]
}

module "bastion_autoscale_group" {
  source  = "cloudposse/ec2-autoscale-group/aws"
  version = "0.35.1"

  image_id                    = join("", data.aws_ami.bastion_image[*].id)
  instance_type               = var.instance_type
  subnet_ids                  = local.vpc_subnet_ids
  health_check_type           = "EC2"
  min_size                    = 1
  max_size                    = 2
  default_cooldown            = 300
  scale_down_cooldown_seconds = 300
  wait_for_capacity_timeout   = "10m"
  user_data_base64            = join("", data.cloudinit_config.config[0][*].rendered)
  tags                        = module.this.tags
  security_group_ids          = [module.sg.id]
  iam_instance_profile_name   = join("", aws_iam_instance_profile.default[*].name)
  block_device_mappings       = []
  associate_public_ip_address = var.associate_public_ip_address

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = 80
  cpu_utilization_low_threshold_percent  = 20

  context = module.this.context
}
