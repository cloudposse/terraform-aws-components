provider "aws" {
  alias  = "prod"
  region = var.region

  assume_role {
    role_arn = coalesce(var.import_role_arn, module.iam_roles["prod"].terraform_role_arn)
  }
}

provider "aws" {
  alias  = "staging"
  region = var.region

  assume_role {
    role_arn = coalesce(var.import_role_arn, module.iam_roles["staging"].terraform_role_arn)
  }
}

provider "aws" {
  alias  = "dev"
  region = var.region

  assume_role {
    role_arn = coalesce(var.import_role_arn, module.iam_roles["dev"].terraform_role_arn)
  }
}

module "tgw_vpc_attachment_dev" {
  source = "./modules/standard_vpc_attachment"

  owning_account = "dev"
  providers = {
    aws = aws.dev
  }

  tgw_config = local.tgw_config
  context    = module.this.context
}

module "tgw_vpc_attachment_prod" {
  source = "./modules/standard_vpc_attachment"

  owning_account = "prod"
  providers = {
    aws = aws.prod
  }

  tgw_config = local.tgw_config
  context    = module.this.context
}

module "tgw_vpc_attachment_staging" {
  source = "./modules/standard_vpc_attachment"

  owning_account = "staging"
  providers = {
    aws = aws.staging
  }

  tgw_config = local.tgw_config
  context    = module.this.context
}

locals {
  tgw_vpc_attachments_config = {
    "dev"     = module.tgw_vpc_attachment_dev.tg_config,
    "prod"    = module.tgw_vpc_attachment_prod.tg_config,
    "staging" = module.tgw_vpc_attachment_staging.tg_config
  }
}
