output "catalog_table_id" {
  description = "Catalog table ID"
  value       = module.glue_catalog_table.id
}

output "catalog_table_name" {
  description = "Catalog table name"
  value       = module.glue_catalog_table.name
}

output "catalog_table_arn" {
  description = "Catalog table ARN"
  value       = module.glue_catalog_table.arn
}
