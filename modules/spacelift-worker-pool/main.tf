locals {
  vpc_id = module.vpc.outputs.vpc_id

  private_subnet_ids  = module.vpc.outputs.private_subnet_ids
  identity_account_id = module.account_map.outputs.full_account_map["identity"]
  ecr_account_id      = module.account_map.outputs.full_account_map[var.ecr_account_name]

  ecr_infrastructure_arn = module.ecr.outputs.ecr_repo_arn_map[var.ecr_repo_name]
}

# Create our worker pool in Spacelift
resource "spacelift_worker_pool" "primary" {
  name        = "Primary EC2 Workers"
  description = "Deployed to ${var.region} within '${var.stage}' AWS account"
}

resource "aws_security_group" "spacelift" {
  name        = "spacelift"
  description = "Security group for Spacelift EC2 instances"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Deploy our Spacelift worker pool in EC2
module "spacelift_ec2_workerpool" {
  source  = "spacelift.io/spacelift-io/spacelift-workerpool-on-ec2/aws"
  version = "1.0.0"

  configuration = <<-EOT
  $(aws --region ${var.region} ecr get-login --registry-ids ${local.ecr_account_id} --no-include-email)
  docker pull ${var.spacelift_runner_image}
  export SPACELIFT_POOL_PRIVATE_KEY=${spacelift_worker_pool.primary.private_key}
  export SPACELIFT_TOKEN=${spacelift_worker_pool.primary.config}
  export SPACELIFT_WHITELIST_ENVS=AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN
  export SPACELIFT_MASK_ENVS=AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN
  EOT

  vpc_subnets       = local.private_subnet_ids
  worker_pool_id    = spacelift_worker_pool.primary.id
  security_groups   = [aws_security_group.spacelift.id]
  ami_id            = var.spacelift_ami_id
  ec2_instance_type = var.ec2_instance_type
}

data "aws_iam_policy_document" "spacelift_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      format("arn:aws:iam::%s:role/%s-gbl-identity-ops", local.identity_account_id, var.namespace)
    ]
  }
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [local.ecr_infrastructure_arn]
  }
}

resource "aws_iam_role_policy" "spacelift_role_policy" {
  name   = "SpaceliftRolePolicy"
  role   = module.spacelift_ec2_workerpool.instances_role_name
  policy = data.aws_iam_policy_document.spacelift_role_policy_document.json
}
