terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Starting with v4.8.0, the provider adds `aws_cognito_user_in_group` allowing adding Cognito Users to Cognito Groups in terraform
      # https://github.com/hashicorp/terraform-provider-aws/releases
      version = ">= 4.8.0"
    }
  }
}
