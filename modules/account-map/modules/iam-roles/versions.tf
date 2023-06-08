terraform {
  required_version = ">= 1.2.0"

  required_providers {
    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.16.0"
    }
  }
}
