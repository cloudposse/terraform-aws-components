terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 2.18.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.2"
    }
  }
}
