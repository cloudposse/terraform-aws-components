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
      version = ">= 1.11.2"
    }
    sdm = {
      source  = "strongdm/sdm"
      version = ">= 1.0.19"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.2"
    }
  }
}
