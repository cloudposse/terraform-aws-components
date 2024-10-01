provider "aws" {
  alias = "accepter"

  region = var.accepter_region

  assume_role {
    role_arn = local.accepter_aws_assume_role_arn
  }
}
