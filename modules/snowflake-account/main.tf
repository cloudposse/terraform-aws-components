locals {
  enabled = module.introspection.enabled

  snowflake_user_email = format(module.account.outputs.account_email_format, module.introspection.stage)

  ssm_path_admin_user_name            = format(var.ssm_path_snowflake_user_format, "snowflake", var.snowflake_account, "users", local.admin_username, "username")
  ssm_path_admin_user_password        = format(var.ssm_path_snowflake_user_format, "snowflake", var.snowflake_account, "users", local.admin_username, "password")
  ssm_path_terraform_user_name        = format(var.ssm_path_snowflake_user_format, "snowflake", var.snowflake_account, "users", local.terraform_username, "username")
  ssm_path_terraform_user_password    = format(var.ssm_path_snowflake_user_format, "snowflake", var.snowflake_account, "users", local.terraform_username, "password")
  ssm_path_terraform_user_private_key = format(var.ssm_path_snowflake_user_format, "snowflake", var.snowflake_account, "users", local.terraform_username, "private_key")

  # Fixed username given manually during Snowflake account creation.
  # This user is only used to create the terraform service user
  admin_username = var.snowflake_admin_username

  terraform_username = format(var.snowflake_username_format, module.snowflake_account.id, var.service_user_id)

  snowflake_terraform_role = local.enabled ? module.snowflake_role.id : ""
}

module "utils" {
  source  = "cloudposse/utils/aws"
  version = "0.8.1"
  context = module.introspection.context
}

module "snowflake_account" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # Change to use the Snowflake region, typically the same as the given stack
  environment = lookup(module.utils.region_az_alt_code_maps["to_short"], var.snowflake_account_region)

  context = module.introspection.context
}

# Identifier for the virtual warehouse; must be unique for your account. In addition, the identifier must start with an alphabetic character and cannot contain spaces or special characters unless the entire identifier string is enclosed in double quotes (e.g. "My object" ).
module "snowflake_warehouse" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # Change to use the Snowflake region, typically the same as the given stack
  environment = lookup(module.utils.region_az_alt_code_maps["to_short"], var.snowflake_account_region)

  attributes = ["default", "wh"]

  # Hyphens are not allowed, but underscores are allowed
  delimiter = "_"

  # Since Warehouse names are case-sensitive, best practice is to make all names upper case
  label_value_case = "upper"

  context = module.introspection.context
}

resource "snowflake_warehouse" "default" {
  count = local.enabled ? 1 : 0

  name           = module.snowflake_warehouse.id
  comment        = "The default warehouse used to hold required users."
  warehouse_size = var.default_warehouse_size
}

resource "random_password" "terraform_user_password" {
  count = local.enabled ? 1 : 0

  length           = 16
  special          = true
  override_special = "_%@"
}

resource "tls_private_key" "terraform_user_key" {
  count = local.enabled ? 1 : 0

  algorithm = "RSA"
}

resource "snowflake_user" "terraform" {
  count = local.enabled ? 1 : 0

  name       = "Snowflake Terraform User"
  login_name = local.terraform_username
  comment    = "Terraform service user"
  password   = random_password.terraform_user_password[0].result

  disabled     = false
  display_name = local.terraform_username
  email        = local.snowflake_user_email

  first_name = var.terraform_user_first_name
  last_name  = var.terraform_user_last_name

  default_warehouse = snowflake_warehouse.default[0].name
  default_role      = snowflake_role.terraform[0].name

  # Key must be in a single line string with the ---*--- prefix and suffix removed
  rsa_public_key = replace(trimsuffix(trimprefix(chomp(tls_private_key.terraform_user_key[0].public_key_pem), "-----BEGIN PUBLIC KEY-----"), "-----END PUBLIC KEY-----"), "\n", "")

  must_change_password = false
}

# The identifier must start with an alphabetic character and cannot contain spaces or special characters unless the entire identifier string is enclosed in double quotes (e.g. "My object"). Identifiers enclosed in double quotes are also case-sensitive.
module "snowflake_role" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  environment      = lookup(module.utils.region_az_alt_code_maps["to_short"], var.snowflake_account_region)
  attributes       = ["terraform", "role"]
  delimiter        = ""
  label_value_case = "title"

  context = module.introspection.context
}

# Snowflake recommends using custom roles in all cases. Assign system roles to those custom roles to grant appropriate permission.
resource "snowflake_role" "terraform" {
  count = local.enabled ? 1 : 0

  name    = module.snowflake_role.id
  comment = var.snowflake_role_description
}

resource "snowflake_role_grants" "grant_system_roles" {
  count = local.enabled ? 1 : 0

  role_name = "ACCOUNTADMIN"

  # Snowflake resource names are enclosed in quotes intentionally per Idenitier Requirements:
  # https://docs.snowflake.com/en/sql-reference/identifiers-syntax.html#identifier-requirements
  roles = [
    "${snowflake_role.terraform[0].name}",
  ]
}

resource "snowflake_role_grants" "grant_custom_roles" {
  count = local.enabled ? 1 : 0

  role_name = snowflake_role.terraform[0].name

  # Snowflake resource names are enclosed in quotes intentionally per Idenitier Requirements:
  # https://docs.snowflake.com/en/sql-reference/identifiers-syntax.html#identifier-requirements
  users = [
    "${snowflake_user.terraform[0].name}",
  ]
}

module "ssm_parameters" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.9.1"

  parameter_write = [
    {
      name        = local.ssm_path_admin_user_name
      value       = local.admin_username
      type        = "String"
      overwrite   = "false"
      description = "Snowflake Admin User Name"
    },
    {
      name        = local.ssm_path_terraform_user_name
      value       = local.terraform_username
      type        = "String"
      overwrite   = "false"
      description = "Snowflake Terraform User Name"
    },
    {
      name        = local.ssm_path_terraform_user_password
      value       = random_password.terraform_user_password[0].result
      type        = "SecureString"
      overwrite   = "false"
      description = "Snowflake Terraform User Password"
    },
    {
      name        = local.ssm_path_terraform_user_private_key
      value       = tls_private_key.terraform_user_key[0].private_key_pem
      type        = "SecureString"
      overwrite   = "false"
      description = "Snowflake Terraform User Private Key"
    }
  ]

  context = module.introspection.context
}
