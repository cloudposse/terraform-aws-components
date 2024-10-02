locals {
  enabled = module.this.enabled

  vpc_id = module.vpc.outputs.vpc_id
  # basic usage picks the first private subnet from the vpc component
  vpc_private_subnet_ids = sort(module.vpc.outputs.private_subnet_ids)
  subnet_id              = local.vpc_private_subnet_ids[0]
}

data "aws_ami" "this" {
  count = local.enabled ? 1 : 0

  most_recent = true
  owners      = [var.ami_owner]
  name_regex  = var.ami_name_regex

  dynamic "filter" {
    for_each = toset(var.ami_filters)
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

data "template_file" "userdata" {
  count    = local.enabled ? 1 : 0
  template = file("${path.module}/templates/userdata.sh.tmpl")

  vars = {
    user_data = var.user_data
  }
}

module "ec2_instance" {
  source  = "cloudposse/ec2-instance/aws"
  version = "1.4.0"

  enabled = local.enabled

  ami              = local.enabled ? data.aws_ami.this[0].id : ""
  ami_owner        = var.ami_owner
  instance_type    = var.instance_type
  user_data_base64 = local.enabled ? base64encode(data.template_file.userdata[0].rendered) : ""

  subnet               = local.subnet_id
  vpc_id               = local.vpc_id
  security_group_rules = var.security_group_rules

  context = module.this.context
}
