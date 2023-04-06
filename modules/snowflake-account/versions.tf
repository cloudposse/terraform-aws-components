terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = ">= 0.25"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3"
    }
  }
}
