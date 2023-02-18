terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.19"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 2.1.0"
    }
  }
}
