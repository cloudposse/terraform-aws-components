terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

# Change in 2.2.1 breaks
# module.default_backend_web_app.module.ecs_codepipeline.module.github_webhooks.provider.github
provider "github" {
  version = "2.2.0"
}
