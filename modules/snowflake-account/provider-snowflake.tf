data "aws_ssm_parameter" "snowflake_password" {
  count           = local.enabled ? 1 : 0
  name            = local.ssm_path_admin_user_password
  with_decryption = true
}

provider "snowflake" {
  account  = var.snowflake_account
  region   = "${var.snowflake_account_region}.aws" # required to append ".aws" to region, see https://github.com/chanzuckerberg/terraform-provider-snowflake/issues/529
  username = local.admin_username
  password = data.aws_ssm_parameter.snowflake_password[0].value
}
