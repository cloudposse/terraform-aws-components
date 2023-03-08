terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
    jq = {
      source  = "massdriver-cloud/jq"
      version = ">= 0.2.1"
    }
  }
}
