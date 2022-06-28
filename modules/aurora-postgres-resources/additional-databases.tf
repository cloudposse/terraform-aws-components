resource "postgresql_database" "additional" {
  for_each = local.enabled ? var.additional_databases : []
  name     = each.key
}
