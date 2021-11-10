terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.14.0"
    }
  }
}
