terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.9.0"
      configuration_aliases = [aws.us-east-1]
    }
  }
}
