locals {
  enabled = module.this.enabled

  physical_connection_enabled = local.enabled && var.physical_connection_enabled

  subnet_id = local.physical_connection_enabled ? module.vpc.outputs.private_subnet_ids[0] : null

  availability_zone = local.physical_connection_enabled ? data.aws_subnet.selected[0].availability_zone : null

  physical_connection_requirements = local.physical_connection_enabled ? {
    # List of security group IDs used by the connection
    security_group_id_list = [module.security_group.id]
    # The availability zone of the connection. This field is redundant and implied by subnet_id, but is currently an API requirement
    availability_zone = local.availability_zone
    # The subnet ID used by the connection
    subnet_id = local.subnet_id
  } : null

  username = var.ssm_path_username != null ? join("", data.aws_ssm_parameter.user.*.value) : null
  password = var.ssm_path_password != null ? join("", data.aws_ssm_parameter.password.*.value) : null
  endpoint = var.ssm_path_endpoint != null ? join("", data.aws_ssm_parameter.endpoint.*.value) : null
}

data "aws_subnet" "selected" {
  count = local.physical_connection_enabled ? 1 : 0

  id = local.subnet_id
}

module "glue_connection" {
  source  = "cloudposse/glue/aws//modules/glue-connection"
  version = "0.4.0"

  connection_name                  = var.connection_name
  connection_description           = var.connection_description
  catalog_id                       = var.catalog_id
  connection_type                  = var.connection_type
  connection_properties            = {
    JDBC_CONNECTION_URL = "jdbc:${var.db_type}://${local.endpoint}/${var.connection_db_name}"
    USERNAME            = local.username
    PASSWORD            = local.password
  }
  match_criteria                   = var.match_criteria
  physical_connection_requirements = local.physical_connection_requirements

  context = module.this.context
}

data "aws_ssm_parameter" "endpoint" {
  name = var.ssm_path_endpoint
}

data "aws_ssm_parameter" "user" {
  name = var.ssm_path_username
}

data "aws_ssm_parameter" "password" {
  name = var.ssm_path_password
}
