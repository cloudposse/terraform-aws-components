locals {
  enabled = module.this.enabled
  vpc_id  = module.vpc.outputs.vpc_id
  # Make sure local.vpc_private_subnet_ids is sorted so the order does not change
  vpc_private_subnet_ids                = sort(module.vpc.outputs.private_subnet_ids)
  ssm_enabled                           = local.enabled && var.aws_ssm_enabled
  instances_role_arns                   = local.ssm_enabled ? toset(module.ec2_zscaler[*].role) : []
  eks_outputs                           = module.eks.outputs
  eks_cluster_managed_security_group_id = local.eks_outputs.eks_cluster_managed_security_group_id
  ami_owner                             = var.ami_owner
  ami_name_regex                        = var.ami_regex
}

data "aws_ami" "amazon_linux_2" {
  count       = local.enabled ? 1 : 0
  most_recent = true
  owners      = [local.ami_owner]
  name_regex  = local.ami_name_regex

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ssm_parameter" "zscaler_key" {
  count           = local.enabled && var.secrets_store_type == "SSM" ? 1 : 0
  name            = format("/%s", var.zscaler_key)
  with_decryption = true
}

data "template_file" "userdata" {
  count    = local.enabled ? 1 : 0
  template = file("${path.module}/templates/userdata.sh.tmpl")

  vars = {
    key    = data.aws_ssm_parameter.zscaler_key[0].value
    region = var.region
  }
}

module "ec2_zscaler" {
  count = var.zscaler_count

  source       = "cloudposse/ec2-instance/aws"
  version      = "0.32.2"
  ami          = local.enabled ? data.aws_ami.amazon_linux_2[0].id : ""
  ssh_key_pair = null
  ami_owner    = local.ami_owner
  vpc_id       = local.vpc_id
  # Make sure local.vpc_private_subnet_ids is sorted so the order does not change
  subnet                        = local.vpc_private_subnet_ids[count.index % length(local.vpc_private_subnet_ids)]
  create_default_security_group = false
  security_groups               = [local.eks_cluster_managed_security_group_id]
  instance_type                 = var.instance_type
  # Zscaler is not compatible with IMDSv2
  metadata_http_tokens_required        = false
  metadata_http_put_response_hop_limit = 3
  user_data_base64                     = local.enabled ? base64encode(data.template_file.userdata[0].rendered) : ""
  attributes                           = [count.index]

  context = module.this.context
}

# Attach Amazon's managed policy for SSM managed instance
resource "aws_iam_role_policy_attachment" "ssm_core" {
  for_each   = local.enabled ? local.instances_role_arns : []
  role       = each.key
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
