output "region_node_groups" {
  description = "A map of availability zones to EKS node groups"
  value       = { for availability_zone, node_group in module.node_group : availability_zone => node_group.node_group }
}
