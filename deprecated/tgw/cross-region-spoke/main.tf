locals {
  enabled          = module.this.enabled
  home_environment = module.az_abbreviation.region_az_alt_code_maps[var.aws_region_abbreviation][var.home_region.region]
}

module "az_abbreviation" {
  source  = "cloudposse/utils/aws"
  version = "1.0.0"
}

# This Component primarily lives in
# - routes-home-region.tf
# - routes-this-region.tf
