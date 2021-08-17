output "id" {
  description = "ID of the created example"
  value       = module.example.id
}

output "example" {
  description = "Output \"example\" from example module"
  value       = module.example.example
}

output "random" {
  description = "Output \"random\" from example module"
  value       = module.example.random
}
