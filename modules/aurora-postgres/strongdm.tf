variable "sdm_enabled" {
  type        = bool
  description = "Set to `true` to enable strongdm."
  default     = false
}

variable "sdm_ssm_region" {
  type        = string
  description = "AWS Region housing SSM parameters"
}

variable "sdm_ssm_account" {
  type        = string
  description = "Account (stage) housing SSM parameters"
}


data "aws_ssm_parameter" "api_access_key" {
  count    = local.sdm_enabled ? 1 : 0
  name     = "/vpn/sdm/api_access_key"
  provider = aws.sdm_api_keys
}

data "aws_ssm_parameter" "api_secret_key" {
  count    = local.sdm_enabled ? 1 : 0
  name     = "/vpn/sdm/api_secret_key"
  provider = aws.sdm_api_keys
}

locals {
  sdm_enabled = local.enabled && var.sdm_enabled
  db_config = {
    cluster  = module.primary_aurora_postgres_cluster.cluster_identifier
    database = local.database_name
    hostname = module.primary_aurora_postgres_cluster.master_host
    port     = var.db_port
    username = module.primary_aurora_postgres_cluster.master_username
    password = local.admin_password
  }
}

data "sdm_role" "db_user" {
  count = local.sdm_enabled ? 1 : 0
  name  = "db-user"
}

resource "sdm_resource" "postgres_cluster_admin" {
  count = local.sdm_enabled ? 1 : 0

  aurora_postgres {
    name = local.db_config.cluster

    hostname = local.db_config.hostname
    port     = local.db_config.port

    username = local.db_config.username
    password = local.db_config.password

    database = local.db_config.database

    override_database = false
  }
}

resource "sdm_role_grant" "postgres" {
  count = local.sdm_enabled ? 1 : 0

  role_id     = data.sdm_role.db_user[0].roles[0].id
  resource_id = sdm_resource.postgres_cluster_admin[0].id
}


resource "sdm_resource" "postgres_cluster_ro" {
  count = local.sdm_enabled ? 1 : 0

  aurora_postgres {
    name = "${local.db_config.cluster}_ro"

    hostname = local.db_config.hostname
    port     = local.db_config.port

    username = module.read_only_cluster_user[0].db_user
    password = module.read_only_cluster_user[0].db_user_password

    database = local.db_config.database

    override_database = false
  }
}

resource "sdm_role_grant" "postgres_cluster_ro" {
  count = local.sdm_enabled ? 1 : 0

  role_id     = data.sdm_role.db_user[0].roles[0].id
  resource_id = sdm_resource.postgres_cluster_ro[0].id
}

resource "sdm_resource" "postgres_users" {
  for_each = local.sdm_enabled ? var.additional_users : {}

  aurora_postgres {
    name = "${local.db_config.cluster}_${each.key}"

    hostname = local.db_config.hostname
    port     = local.db_config.port

    username = module.additional_users[each.key].db_user
    password = module.additional_users[each.key].db_user_password

    database = each.value.grants[0].db

    override_database = false
  }
}

resource "sdm_role_grant" "postgres_users" {
  for_each = local.sdm_enabled ? var.additional_users : {}

  role_id     = data.sdm_role.db_user[0].roles[0].id
  resource_id = sdm_resource.postgres_users[each.key].id
}

resource "sdm_resource" "postgres_ro_users" {
  for_each = local.sdm_enabled ? local.all_databases : []

  aurora_postgres {
    name = "${local.db_config.cluster}_${each.key}_ro"

    hostname = local.db_config.hostname
    port     = local.db_config.port

    username = module.read_only_db_users[each.key].db_user
    password = module.read_only_db_users[each.key].db_user_password

    database = each.key

    override_database = true
  }
}

resource "sdm_role_grant" "postgres_ro_users" {
  for_each = local.sdm_enabled ? local.all_databases : []

  role_id     = data.sdm_role.db_user[0].roles[0].id
  resource_id = sdm_resource.postgres_ro_users[each.key].id
}

output "datasource_names" {
  description = "All the data source names."
  value = local.sdm_enabled ? flatten(concat(
    [local.db_config.cluster, "${local.db_config.cluster}_ro"],
    [for k, v in local.restricted_users_map : "${local.db_config.cluster}_${k}"],
    [for k in local.all_databases : "${local.db_config.cluster}_${k}_ro"]
  )) : null
}
