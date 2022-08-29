terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    opsgenie = {
      source  = "opsgenie/opsgenie"
      version = ">= 0.6.7"
    }
  }
}
