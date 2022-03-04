terraform {
  required_version = ">= 0.13.0"

  required_providers {
    opsgenie = {
      source  = "opsgenie/opsgenie"
      version = ">= 0.4"
    }
  }
}
