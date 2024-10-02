terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    # terraform-providers/mysql is archived
    # https://github.com/hashicorp/terraform-provider-mysql
    # replacing with petoju/terraform-provider-mysql
    mysql = {
      source  = "petoju/mysql"
      version = ">= 3.0.22"
    }
  }
}
