locals {
  cluster_ro_user = "cluster_ro"

  all_databases = local.enabled ? toset(compact(concat([local.database_name], tolist(var.additional_databases)))) : []

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

  # Need a placeholder for the derived admin_user so that we can use users_map in for_each
  admin_user_placeholder = "+ADMIN_USER+"

  user_dbs = merge({ for service, v in var.additional_users : v.db_user => distinct([for g in v.grants : g.db if g.object_type == "database"]) },
  { (local.admin_user_placeholder) = local.all_databases })

  users_map = merge(flatten([for u, dbs in local.user_dbs : { for db in dbs : "${db}_${u}" => {
    user = u
    db   = db
    }
    if local.enabled
  }])...)

  #  all_users_map = merge(local.users_map, {
  #    for db in local.all_databases : "${local.cluster_ro_user}_${db}" => {
  #    user = local.cluster_ro_user
  #    db = db
  #  }
  #  })

  read_only_users = local.enabled ? merge(module.read_only_db_users,
  { cluster = module.read_only_cluster_user[0] }) : {}

  sanitized_ro_users = { for k, v in local.read_only_users : k => { for kk, vv in v : kk => vv if kk != "db_user_password" } }
}

module "read_only_db_users" {
  source = "./modules/postgresql-user"

  for_each = local.all_db_ro_grants

  enabled = local.enabled

  service_name    = each.key
  db_user         = "${each.key}_ro"
  db_password     = ""
  ssm_path_prefix = join("/", compact([local.ssm_path_prefix, local.cluster_name, "read-only"]))

  grants = each.value

  context = module.this.context

  depends_on = [
    postgresql_database.additional
  ]
}

module "read_only_cluster_user" {
  source = "./modules/postgresql-user"

  count = local.enabled ? 1 : 0

  enabled         = local.enabled
  service_name    = "cluster"
  db_user         = local.cluster_ro_user
  db_password     = ""
  ssm_path_prefix = join("/", compact([local.ssm_path_prefix, local.cluster_name, "read-only"]))

  grants = flatten(values(local.all_db_ro_grants))

  context = module.this.context

  depends_on = [
    postgresql_database.additional
  ]
}

resource "postgresql_default_privileges" "read_only_tables_users" {
  for_each = local.users_map

  role     = "${each.value.db}_ro"
  database = each.value.db
  schema   = "public"

  owner       = each.value.user == local.admin_user_placeholder ? local.admin_user : each.value.user
  object_type = "table"
  privileges  = ["SELECT"]

  depends_on = [
    module.read_only_db_users,
    module.read_only_cluster_user,
    postgresql_database.additional
  ]
}

resource "postgresql_default_privileges" "read_only_tables_cluster" {
  for_each = local.users_map

  role     = local.cluster_ro_user
  database = each.value.db
  schema   = "public"

  owner       = each.value.user == local.admin_user_placeholder ? local.admin_user : each.value.user
  object_type = "table"
  privileges  = ["SELECT"]

  depends_on = [
    module.read_only_db_users,
    module.read_only_cluster_user,
    postgresql_database.additional
  ]
}
