terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

variable "GITHUB_WEBHOOKS_TOKEN" {
  type        = "string"
  description = "GitHub Webhook Token with permissions to access private repositories"
}

provider "github" {
  token        = "${var.GITHUB_WEBHOOKS_TOKEN}"
  organization = "${var.atlantis_repo_owner}"
}
