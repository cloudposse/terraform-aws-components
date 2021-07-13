locals {
  enabled         = module.this.enabled
  route53_enabled = local.enabled && (try(length(var.route53_zone_name), 0) > 0 || try(length(var.route53_zone_id), 0) > 0)
  ssh_key_enabled = local.enabled && var.ssh_key_enabled

  vpc_id                 = module.vpc.outputs.vpc_id
  vpc_private_subnet_ids = module.vpc.outputs.private_subnet_ids
  vpc_public_subnet_ids  = module.vpc.outputs.public_subnet_ids
  vpc_subnet_ids         = var.associate_public_ip_address ? local.vpc_public_subnet_ids : local.vpc_private_subnet_ids

  bastion_subnet = slice(local.vpc_subnet_ids, 0, 1)

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

data "aws_route53_zone" "route53_zone" {
  count   = local.route53_enabled ? 1 : 0
  zone_id = try(length(var.route53_zone_id), 0) > 0 ? var.route53_zone_id : null
  name    = try(length(var.route53_zone_name), 0) > 0 ? var.route53_zone_name : null
}

module "aws_key_pair" {
  source  = "cloudposse/key-pair/aws"
  version = "0.18.1"

  attributes          = ["ssh", "key"]
  ssh_public_key_path = var.ssh_key_path
  generate_ssh_key    = local.ssh_key_enabled

  enabled = local.ssh_key_enabled
  context = module.this.context
}

data "cloudinit_config" "config" {
  count         = local.enabled ? 1 : 0
  gzip          = false
  base64_encode = true

  dynamic "part" {
    for_each = var.container_enabled ? [1] : []

    content {
      content_type = "text/cloud-config"
      filename     = "cloud-config.yaml"
      content      = local.cloudwatch_agent_config
    }
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "user-data.sh"
    content = templatefile(local.userdata_template, {
      ssh_pub_keys = var.ssh_pub_keys
    })
  }
}

module "ec2_bastion" {
  source  = "cloudposse/ec2-bastion-server/aws"
  version = "0.28.3"

  instance_type = var.instance_type
  ## Use only one availability zone to be sure volume will be in the same zone
  subnets                       = local.bastion_subnet
  vpc_id                        = local.vpc_id
  root_block_device_volume_size = var.root_block_device_volume_size
  associate_public_ip_address   = var.associate_public_ip_address
  # Version 0.25.0 of this module did not assign an EIP, so we do it
  # in this component. Preserve backward compatibility by disabling it.
  assign_eip_address = false
  zone_id            = local.route53_enabled ? data.aws_route53_zone.route53_zone[0].id : null
  host_name          = var.custom_bastion_hostname

  ebs_block_device_volume_size = var.ebs_block_device_volume_size
  ebs_delete_on_termination    = var.ebs_delete_on_termination
  user_data_base64             = join("", data.cloudinit_config.config.*.rendered)
  security_group_rules         = var.security_group_rules
  key_name                     = module.aws_key_pair.key_name
  instance_profile             = join("", aws_iam_instance_profile.default.*.name)

  ssm_enabled = var.ssm_enabled

  context = module.this.context
}

resource "aws_ssm_parameter" "ssh_private_key" {
  count = local.ssh_key_enabled ? 1 : 0

  name        = format("/%s/%s", "bastion", "ssh_private_key")
  value       = module.aws_key_pair.private_key
  description = "SSH Private key for bastion key-pair"
  type        = "SecureString"
  key_id      = var.kms_alias_name_ssm
  overwrite   = true
}
