terraform {
  required_version = ">= 1.0.0"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 0.1.31"
    }
  }
}
