provider "awsutils" {
  # Components may want to use awsutils, and when they do, they typically want to use it in the assumed IAM role.
  # That conflicts with this module's needs, so we create a separate provider alias for this module to use.
  alias = "iam-roles"

  # If the provider block is empty, Terraform will output a deprecation warning,
  # because earlier versions of Terraform used empty provider blocks to declare provider requirements,
  # which is now deprecated in favor of the required_providers block.
  # So we add a useless setting to the provider block to avoid the deprecation warning.
  profile = null
}
