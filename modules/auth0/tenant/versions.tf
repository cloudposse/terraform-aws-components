terraform {
  required_version = ">= 1.0.0"

  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = ">= 1.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }
}
