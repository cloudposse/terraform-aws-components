module "additional_users" {
  source = "./modules/postgresql-user"

  for_each = var.additional_users

  enabled = local.enabled

  service_name    = each.key
  db_user         = each.value.db_user
  db_password     = each.value.db_password
  grants          = each.value.grants
  ssm_path_prefix = join("/", compact([local.ssm_path_prefix, local.cluster_name, "service"]))

  context = module.this.context

  depends_on = [
    postgresql_database.additional
  ]
}
