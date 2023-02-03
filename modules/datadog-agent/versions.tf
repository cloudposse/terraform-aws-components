terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 0.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.14.0"
    }
  }
}
