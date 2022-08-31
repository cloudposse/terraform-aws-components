terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Using the latest version of the provider since the earlier versions had many issues with DMS replication tasks.
      # In particular:
      # https://github.com/hashicorp/terraform-provider-aws/pull/24047
      # https://github.com/hashicorp/terraform-provider-aws/pull/23692
      # https://github.com/hashicorp/terraform-provider-aws/pull/13476
      version = ">= 4.26.0"
    }
  }
}
