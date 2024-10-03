terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    template = {
      source  = "cloudposse/template"
      version = ">= 2.2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 1.10.0"
    }
  }
}
