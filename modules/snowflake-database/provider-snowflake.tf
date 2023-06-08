data "aws_ssm_parameter" "snowflake_username" {
  count = local.enabled ? 1 : 0
  name  = module.snowflake_account.outputs.ssm_path_terraform_user_name
}

data "aws_ssm_parameter" "snowflake_private_key" {
  count           = local.enabled ? 1 : 0
  name            = module.snowflake_account.outputs.ssm_path_terraform_user_private_key
  with_decryption = true
}

provider "snowflake" {
  account = local.snowflake_account
  # required to append ".aws" to region, see https://github.com/chanzuckerberg/terraform-provider-snowflake/issues/529
  region      = "${local.snowflake_account_region}.aws"
  username    = data.aws_ssm_parameter.snowflake_username[0].value
  private_key = data.aws_ssm_parameter.snowflake_private_key[0].value
}
