terraform {
  required_version = ">= 1.2.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = ">= 0.5"
    }
  }
}
