output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value       = module.msk_cluster.cluster_arn
}

output "bootstrap_brokers_scram" {
  description = "A comma separated list of one or more DNS names (or IPs) and TLS port pairs kafka brokers suitable to bootstrap connectivity using SASL/SCRAM to the kafka cluster."
  value       = module.msk_cluster.bootstrap_brokers_scram
}

output "bootstrap_brokers_iam" {
  description = "A comma separated list of one or more DNS names (or IPs) and TLS port pairs kafka brokers suitable to bootstrap connectivity using SASL/IAM to the kafka cluster."
  value       = module.msk_cluster.bootstrap_brokers_iam
}

output "current_version" {
  description = "Current version of the MSK Cluster used for updates"
  value       = module.msk_cluster.current_version
}

output "zookeeper_connect_string" {
  description = "A comma separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster"
  value       = module.msk_cluster.zookeeper_connect_string
}

output "config_arn" {
  description = "Amazon Resource Name (ARN) of the configuration"
  value       = module.msk_cluster.config_arn
}

output "latest_revision" {
  description = "Latest revision of the configuration"
  value       = module.msk_cluster.latest_revision
}

output "hostname" {
  description = "Comma separated list of one or more MSK Cluster Broker DNS hostname"
  value       = module.msk_cluster.hostname
}

output "cluster_name" {
  description = "MSK Cluster name"
  value       = module.msk_cluster.cluster_name
}

output "security_group_id" {
  description = "The ID of the security group rule"
  value       = module.msk_cluster.security_group_id
}

output "security_group_name" {
  description = "The name of the security group rule"
  value       = module.msk_cluster.security_group_name
}
