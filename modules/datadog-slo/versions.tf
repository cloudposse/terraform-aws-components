terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.3.0"
    }
  }
}
