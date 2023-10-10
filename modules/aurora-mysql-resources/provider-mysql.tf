variable "mysql_admin_password" {
  type        = string
  description = "MySQL password for the admin user. If not provided, the password will be pulled from SSM"
  default     = ""
}

locals {
  cluster_endpoint = module.aurora_mysql.outputs.aurora_mysql_endpoint

  mysql_admin_user         = module.aurora_mysql.outputs.aurora_mysql_master_username
  mysql_admin_password_key = module.aurora_mysql.outputs.aurora_mysql_master_password_ssm_key
  mysql_admin_password     = local.enabled ? (length(var.mysql_admin_password) > 0 ? var.mysql_admin_password : data.aws_ssm_parameter.mysql_admin_password[0].value) : ""
}

data "aws_ssm_parameter" "admin_password" {
  count = local.enabled && !(length(var.mysql_admin_password) > 0) ? 1 : 0

  name = local.mysql_admin_password_key

  with_decryption = true
}

provider "mysql" {
  endpoint = local.cluster_endpoint
  username = local.mysql_admin_user
  password = local.mysql_admin_password

  # Useful for debugging provider
  # https://github.com/petoju/terraform-provider-mysql/blob/master/mysql/provider.go
  connect_retry_timeout_sec = 60
}
