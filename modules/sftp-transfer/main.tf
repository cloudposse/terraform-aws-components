locals {
  public_subnet_ids = try(module.vpc.outputs.public_subnet_ids, [])
  vpc_id            = try(module.vpc.outputs.vpc_id, null)
  sftp_bucket_name  = module.bucket.outputs.bucket_id
}

resource "aws_security_group" "sftp" {
  name        = "${module.this.id}-sftp-transfer"
  description = "Allow SFTP access from VPC"
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "sftp_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sftp.id
}

resource "aws_eip" "sftp" {
  vpc = local.vpc_id != null
}

module "transfer-sftp" {
  source  = "cloudposse/transfer-sftp/aws"
  version = "0.5.2"

  s3_bucket_name         = local.sftp_bucket_name
  sftp_users             = var.sftp_users
  vpc_id                 = local.vpc_id
  vpc_security_group_ids = [aws_security_group.sftp.id]
  subnet_ids             = length(local.public_subnet_ids) > 0 ? [local.public_subnet_ids[0]] : []
  address_allocation_ids = [aws_eip.sftp.id]

  context = module.this.context
}
