data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

# The Spacelift always validates its credentials, so we always pass api_key_id and api_key_secret
data "aws_ssm_parameter" "spacelift_key_id" {
  name = "/spacelift/key_id"
}

data "aws_ssm_parameter" "spacelift_key_secret" {
  name = "/spacelift/key_secret"
}

data "aws_ami" "spacelift" {
  count = local.enabled && var.spacelift_ami_id == null ? 1 : 0

  owners      = var.custom_spacelift_ami ? ["self"] : [var.spacelift_aws_account_id]
  most_recent = true

  filter {
    name   = "name"
    values = ["spacelift-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
