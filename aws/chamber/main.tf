terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "identity" {
  source = "git::git@github.com:cloudposse/terraform-aws-account-metadata.git?ref=init"
}

module "chamber_kms_key" {
  source      = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=tags/0.1.0"
  namespace   = "${module.identity.namespace}"
  stage       = "${module.identity.stage}"
  name        = "chamber"
  description = "KMS key for chamber"
}

# Chamber user for CI/CD systems that cannot leverage IAM instance profiles
# https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html
module "chamber_user" {
  source        = "git::https://github.com/cloudposse/terraform-aws-iam-chamber-user.git?ref=tags/0.1.3"
  namespace     = "${module.identity.namespace}"
  stage         = "${module.identity.stage}"
  name          = "chamber"
  attributes    = ["codefresh"]
  kms_key_arn   = "${module.chamber_kms_key.key_arn}"
  ssm_resources = ["${format("arn:aws:ssm:%s:%s:parameter/kops/*", module.identity.aws_region, module.identity.account_id)}"]
}
