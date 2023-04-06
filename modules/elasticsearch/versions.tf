terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.8"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
