output "crawler_id" {
  description = "Crawler ID"
  value       = module.glue_crawler.id
}

output "crawler_name" {
  description = "Crawler name"
  value       = module.glue_crawler.name
}

output "crawler_arn" {
  description = "Crawler ARN"
  value       = module.glue_crawler.arn
}
