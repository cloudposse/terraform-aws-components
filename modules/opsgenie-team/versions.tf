terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    opsgenie = {
      source  = "opsgenie/opsgenie"
      version = ">= 0.6.7"
    }
    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.3.0"
    }
  }
}
