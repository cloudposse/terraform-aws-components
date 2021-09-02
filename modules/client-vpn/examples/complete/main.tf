provider "aws" {
  region = var.region
}

module "example" {
  source = "../../"

  region = var.region

  client_cidr = var.client_cidr

  aws_subnet_id = var.aws_subnet_id

  organization_name = var.organization_name

  aws_authorization_rule_target_cidr = var.aws_authorization_rule_target_cidr

  logging_enabled = var.logging_enabled

  logs_retention = var.logs_retention

  internet_access_enabled = var.internet_access_enabled
}
