terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    template = {
      source  = "cloudposse/template"
      version = ">= 2.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.3"
    }
  }
}
