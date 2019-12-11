terraform {
  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = string
}

provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}
