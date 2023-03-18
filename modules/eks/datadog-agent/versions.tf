terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.38"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
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
