locals {
  enabled         = module.this.enabled
  route53_enabled = local.enabled && var.associate_public_ip_address && var.custom_bastion_hostname != null && var.vanity_domain != null

  vpc_id                 = module.vpc.outputs.vpc_id
  vpc_private_subnet_ids = module.vpc.outputs.private_subnet_ids
  vpc_public_subnet_ids  = module.vpc.outputs.public_subnet_ids
  vpc_subnet_ids         = var.associate_public_ip_address ? local.vpc_public_subnet_ids : local.vpc_private_subnet_ids

  bastion_subnet = slice(local.vpc_subnet_ids, 0, 1)
  bastion_az     = module.vpc.outputs.availability_zones[0]

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

data "aws_route53_zone" "vanity" {
  count = local.route53_enabled ? 1 : 0
  name  = var.vanity_domain
}

resource "aws_route53_record" "default" {
  count   = local.route53_enabled ? 1 : 0
  zone_id = join("", data.aws_route53_zone.vanity.*.zone_id)
  name    = "${var.custom_bastion_hostname}.${var.vanity_domain}"
  type    = "A"
  ttl     = "300"
  records = aws_eip.static.*.public_ip
}

module "aws_key_pair" {
  source              = "cloudposse/key-pair/aws"
  version             = "0.18.1"
  attributes          = ["ssh", "key"]
  ssh_public_key_path = var.ssh_key_path
  generate_ssh_key    = var.generate_ssh_key

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

resource "aws_eip" "static" {
  count = local.enabled ? 1 : 0
  vpc   = true
}

module "ec2_bastion" {
  source  = "cloudposse/ec2-bastion-server/aws"
  version = "0.28.1"

  instance_type = var.instance_type
  ## Use only one availability zone to be sure volume will be in the same zone
  subnets                       = local.bastion_subnet
  vpc_id                        = local.vpc_id
  root_block_device_volume_size = var.root_block_device_volume_size
  associate_public_ip_address   = var.associate_public_ip_address
  # Version 0.25.0 of this module did not assign an EIP, so we do it
  # in this component. Preserve backward compatibility by disabling it.
  assign_eip_address = false

  ebs_block_device_volume_size = 0
  ebs_delete_on_termination    = var.ebs_delete_on_termination
  user_data_base64             = join("", data.cloudinit_config.config.*.rendered)
  security_group_rules         = var.security_group_rules
  key_name                     = module.aws_key_pair.key_name
  instance_profile             = join("", aws_iam_instance_profile.default.*.name)

  ssm_enabled = var.ssm_enabled

  context = module.this.context
}

resource "aws_ebs_volume" "default" {
  count             = local.enabled ? 1 : 0
  availability_zone = local.bastion_az
  size              = var.ebs_block_device_volume_size
  encrypted         = true
}

resource "aws_volume_attachment" "default" {
  count = local.enabled ? 1 : 0

  ## Use /dev/sdh as this is default device name for bastion
  device_name = "/dev/sdh"
  instance_id = module.ec2_bastion.instance_id
  volume_id   = aws_ebs_volume.default[0].id
}

resource "aws_eip_association" "static" {
  count         = local.enabled ? 1 : 0
  instance_id   = module.ec2_bastion.instance_id
  allocation_id = join("", aws_eip.static.*.id)
}

resource "aws_ssm_parameter" "ssh_private_key" {
  count = var.generate_ssh_key ? 1 : 0

  name        = format("/%s/%s", "bastion", "ssh_private_key")
  value       = module.aws_key_pair.private_key
  description = "SSH Private key for bastion key-pair"
  type        = "SecureString"
  key_id      = var.kms_alias_name_ssm
  overwrite   = true
}
