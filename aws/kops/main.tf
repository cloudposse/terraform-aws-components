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
  source = "git::git@github.com:cloudposse/terraform-aws-account-metadata.git?ref=tags/0.1.2"
}

module "kops_state_backend" {
  source           = "git::https://github.com/cloudposse/terraform-aws-kops-state-backend.git?ref=tags/0.1.3"
  namespace        = "${module.identity.namespace}"
  stage            = "${module.identity.stage}"
  name             = "kops-state"
  cluster_name     = "${module.identity.aws_region}"
  parent_zone_name = "${module.identity.zone_name}"
  zone_name        = "$${name}.$${parent_zone_name}"
  region           = "${module.identity.aws_region}"
}

module "ssh_key_pair" {
  source              = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=tags/0.2.3"
  namespace           = "${module.identity.namespace}"
  stage               = "${module.identity.stage}"
  name                = "kops-${module.identity.aws_region}"
  ssh_public_key_path = "/secrets/tf/ssh"
  generate_ssh_key    = "true"
}
