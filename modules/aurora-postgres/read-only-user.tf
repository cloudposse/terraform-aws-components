variable "read_only_users_enabled" {
  type        = bool
  default     = false
  description = "Set `true` to automatically create read-only users for every database"
}

locals {
  ro_users_enabled = local.enabled && var.read_only_users_enabled
  cluster_ro_user  = "cluster_ro"
  all_databases    = local.ro_users_enabled ? toset(compact(concat([var.db_name], tolist(var.additional_databases)))) : []
  all_db_ro_grants = { for db in local.all_databases : db => [
    {
      grant : ["CONNECT"]
      db : db
      schema : null
      object_type : "database"
    },
    {
      grant : ["USAGE"]
      db : db
      schema : "public"
      object_type : "schema"
    },
    {
      grant : ["SELECT"]
      db : db
      schema : "public"
      object_type : "table"
    },
  ] }
}

module "read_only_db_users" {
  for_each = local.all_db_ro_grants
  source   = "./modules/postgresql-user"

  service_name    = each.key
  db_user         = "${each.key}_ro"
  db_password     = ""
  ssm_path_prefix = format("%v/read-only", local.ssm_key_prefix)

  grants = each.value

  context = module.this.context

  depends_on = [
    module.primary_aurora_postgres_cluster.cluster_identifier,
    postgresql_database.additional,
  ]
}

module "read_only_cluster_user" {
  count  = local.ro_users_enabled ? 1 : 0
  source = "./modules/postgresql-user"

  service_name    = "cluster"
  db_user         = local.cluster_ro_user
  db_password     = ""
  ssm_path_prefix = format("%v/read-only", local.ssm_key_prefix)

  grants = flatten(values(local.all_db_ro_grants))

  context = module.this.context

  depends_on = [
    module.primary_aurora_postgres_cluster.cluster_identifier,
    postgresql_database.additional,
  ]
}

locals {
  # Need a placeholder for the derived admin_user so that we can use users_map in for_each
  admin_user_placeholder = "+ADMIN_USER+"
  user_dbs = merge({ for service, v in var.additional_users : v.db_user => distinct([for g in v.grants : g.db if g.object_type == "database"]) },
  { (local.admin_user_placeholder) = local.all_databases })
  users_map = merge(flatten([for u, dbs in local.user_dbs : { for db in dbs : "${db}_${u}" => {
    user = u
    db   = db
  } }])...)
  restricted_users_map = { for k, v in local.users_map : k => v if v.user != local.admin_user_placeholder }
  #  all_users_map = merge(local.users_map, {
  #    for db in local.all_databases : "${local.cluster_ro_user}_${db}" => {
  #    user = local.cluster_ro_user
  #    db = db
  #  }
  #  })
}

resource "postgresql_default_privileges" "read_only_tables_users" {
  for_each = local.ro_users_enabled ? local.users_map : {}

  role     = "${each.value.db}_ro"
  database = each.value.db
  schema   = "public"

  owner       = each.value.user == local.admin_user_placeholder ? local.admin_user : each.value.user
  object_type = "table"
  privileges  = ["SELECT"]

  depends_on = [
    module.read_only_db_users,
    module.read_only_cluster_user,
    module.primary_aurora_postgres_cluster.cluster_identifier,
  ]
}

resource "postgresql_default_privileges" "read_only_tables_cluster" {
  for_each = local.ro_users_enabled ? local.users_map : {}

  role     = local.cluster_ro_user
  database = each.value.db
  schema   = "public"

  owner       = each.value.user == local.admin_user_placeholder ? local.admin_user : each.value.user
  object_type = "table"
  privileges  = ["SELECT"]

  depends_on = [
    module.read_only_db_users,
    module.read_only_cluster_user,
    module.primary_aurora_postgres_cluster.cluster_identifier,
  ]
}

locals {
  read_only_users = local.ro_users_enabled ? merge(module.read_only_db_users,
  { cluster = module.read_only_cluster_user[0] }) : {}
  sanitized_ro_users = { for k, v in local.read_only_users : k => { for kk, vv in v : kk => vv if kk != "db_user_password" } }
}

output "read_only_users" {
  description = "List of all read only users without a db user password."
  value       = local.ro_users_enabled ? local.sanitized_ro_users : null
}
