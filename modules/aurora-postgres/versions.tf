terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.17.1"
    }
  }
}
