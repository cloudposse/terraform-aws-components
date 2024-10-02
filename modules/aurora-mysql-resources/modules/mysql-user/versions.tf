terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    mysql = {
      source  = "petoju/mysql"
      version = ">= 3.0.22"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.2"
    }
  }
}
