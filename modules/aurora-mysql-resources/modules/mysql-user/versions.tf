terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    mysql = {
      source  = "terraform-providers/mysql"
      version = ">= 1.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.2"
    }
  }
}
