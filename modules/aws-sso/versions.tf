terraform {
  required_version = "~> 1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 0.17.23"
    }
  }
}
