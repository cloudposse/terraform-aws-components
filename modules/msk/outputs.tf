output "cluster_name" {
  value       = module.kafka.cluster_name
  description = "The cluster name of the MSK cluster"
}

output "cluster_arn" {
  value       = module.kafka.cluster_arn
  description = "Amazon Resource Name (ARN) of the MSK cluster"
}

output "storage_mode" {
  value       = module.kafka.storage_mode
  description = "Storage mode for supported storage tiers"
}

output "bootstrap_brokers" {
  value       = module.kafka.bootstrap_brokers
  description = "Comma separated list of one or more hostname:port pairs of Kafka brokers suitable to bootstrap connectivity to the Kafka cluster"
}

output "bootstrap_brokers_tls" {
  value       = module.kafka.bootstrap_brokers_tls
  description = "Comma separated list of one or more DNS names (or IP addresses) and TLS port pairs for access to the Kafka cluster using TLS"
}

output "bootstrap_brokers_public_tls" {
  value       = module.kafka.bootstrap_brokers_public_tls
  description = "Comma separated list of one or more DNS names (or IP addresses) and TLS port pairs for public access to the Kafka cluster using TLS"
}

output "bootstrap_brokers_sasl_scram" {
  value       = module.kafka.bootstrap_brokers_sasl_scram
  description = "Comma separated list of one or more DNS names (or IP addresses) and SASL SCRAM port pairs for access to the Kafka cluster using SASL/SCRAM"
}

output "bootstrap_brokers_public_sasl_scram" {
  value       = module.kafka.bootstrap_brokers_public_sasl_scram
  description = "Comma separated list of one or more DNS names (or IP addresses) and SASL SCRAM port pairs for public access to the Kafka cluster using SASL/SCRAM"
}

output "bootstrap_brokers_sasl_iam" {
  value       = module.kafka.bootstrap_brokers_sasl_iam
  description = "Comma separated list of one or more DNS names (or IP addresses) and SASL IAM port pairs for access to the Kafka cluster using SASL/IAM"
}

output "bootstrap_brokers_public_sasl_iam" {
  value       = module.kafka.bootstrap_brokers_public_sasl_iam
  description = "Comma separated list of one or more DNS names (or IP addresses) and SASL IAM port pairs for public access to the Kafka cluster using SASL/IAM"
}

output "zookeeper_connect_string" {
  value       = module.kafka.zookeeper_connect_string
  description = "Comma separated list of one or more hostname:port pairs to connect to the Apache Zookeeper cluster"
}

output "zookeeper_connect_string_tls" {
  value       = module.kafka.zookeeper_connect_string_tls
  description = "Comma separated list of one or more hostname:port pairs to connect to the Apache Zookeeper cluster via TLS"
}

output "broker_endpoints" {
  value       = module.kafka.broker_endpoints
  description = "List of broker endpoints"
}

output "current_version" {
  value       = module.kafka.current_version
  description = "Current version of the MSK Cluster"
}

output "config_arn" {
  value       = module.kafka.config_arn
  description = "Amazon Resource Name (ARN) of the MSK configuration"
}

output "latest_revision" {
  value       = module.kafka.latest_revision
  description = "Latest revision of the MSK configuration"
}

output "hostnames" {
  value       = module.kafka.hostnames
  description = "List of MSK Cluster broker DNS hostnames"
}

output "security_group_id" {
  value       = module.kafka.security_group_id
  description = "The ID of the created security group"
}

output "security_group_arn" {
  value       = module.kafka.security_group_arn
  description = "The ARN of the created security group"
}

output "security_group_name" {
  value       = module.kafka.security_group_name
  description = "The name of the created security group"
}
