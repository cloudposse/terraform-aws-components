terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      # Version 2.25 and higher have bugs, so we cannot allow them,
      # but automation enforces that we have no upper limit.
      # It is less critical here, because the Kubernetes provider is being removed entirely.
      version = "2.24"
    }
  }
}
