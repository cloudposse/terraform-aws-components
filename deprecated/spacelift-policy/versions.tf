terraform {
  required_version = ">= 1.3"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 0.1.31"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
  }
}
