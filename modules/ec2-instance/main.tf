locals {
  enabled = module.this.enabled

  vpc_id = module.vpc.outputs.vpc_id
  # Make sure local.vpc_private_subnet_ids is sorted so the order does not change
  vpc_private_subnet_ids = sort(module.vpc.outputs.private_subnet_ids)
}

data "aws_ami" "this" {
  count = local.enabled ? 1 : 0

  most_recent = true
  owners      = [var.ami_owner]
  name_regex  = var.ami_name_regex

  dynamic "filter" {
    for_each = var.ami_filters
    content {
      name   = filter.name
      values = filter.values
    }
  }
}

data "template_file" "userdata" {
  count    = local.enabled ? 1 : 0
  template = file("${path.module}/templates/userdata.sh.tmpl")
}

module "ec2-instance" {
  source  = "cloudposse/ec2-instance/aws"
  version = "1.4.0"

  enabled = local.enabled

  ami              = local.enabled ? data.aws_ami.this[0].id : ""
  ami_owner        = var.ami_owner
  instance_type    = var.instance_type
  user_data_base64 = local.enabled ? base64encode(data.template_file.userdata[0].rendered) : ""

  # Make sure local.vpc_private_subnet_ids is sorted so the order does not change
  subnet               = local.vpc_private_subnet_ids[count.index % length(local.vpc_private_subnet_ids)]
  vpc_id               = local.vpc_id
  security_group_rules = var.security_group_rules

  context = module.this.context
}
