provider "aws" {
  region = "us-east-1"
//  alias = "default_aws"
//  assume_role {
//    role_arn = var.assume_arn
//  }
}

provider "aws" {
  region = "us-east-1"
  alias = "assumed_role_aws"
    assume_role {
      role_arn = local.assume_arn
    }
}
