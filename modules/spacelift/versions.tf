terraform {
  required_version = ">= 1.0.0"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 0.1.29"
    }
    utils = {
      source = "cloudposse/utils"
      # problem with 1.4.0
      version = ">= 1.3.0, != 1.4.0"
    }
  }
}
