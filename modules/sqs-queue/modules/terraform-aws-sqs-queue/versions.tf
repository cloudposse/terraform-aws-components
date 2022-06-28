terraform {
  required_version = ">= 0.14"

  required_providers {
    # Update these to reflect the actual requirements of your module
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
