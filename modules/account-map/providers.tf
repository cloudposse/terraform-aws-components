# Unlike all the other modules (besides account), we cannot
# rely on account-map (this module) to tell us which role to use.
# This must be run by a user that inherently has access to
# the Terraform state S3 bucket and DynamoDB tables and can
# read the AWS organization data for the whole organization.

provider "aws" {
  region = var.region
}
