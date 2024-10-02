output "catalog_database_id" {
  description = "Catalog database ID"
  value       = module.glue_catalog_database.id
}

output "catalog_database_name" {
  description = "Catalog database name"
  value       = module.glue_catalog_database.name
}

output "catalog_database_arn" {
  description = "Catalog database ARN"
  value       = module.glue_catalog_database.arn
}
