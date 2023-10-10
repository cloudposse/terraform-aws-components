terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.3"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 1.10.0"
    }
  }
}
