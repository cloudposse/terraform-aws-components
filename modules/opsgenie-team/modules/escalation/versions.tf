terraform {
  required_version = ">= 1.0"

  required_providers {
    opsgenie = {
      source  = "opsgenie/opsgenie"
      version = ">= 0.6.7"
    }
  }
}
