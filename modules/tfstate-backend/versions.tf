terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.16.0"
    }
  }
}
