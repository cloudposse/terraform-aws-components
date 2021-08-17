terraform {
  required_version = ">= 0.12.26"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 1.2"
    }
  }
}
