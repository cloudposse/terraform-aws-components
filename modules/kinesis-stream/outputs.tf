output "name" {
  description = "Name of the Kinesis stream."
  value       = module.kinesis.name
}

output "shard_count" {
  description = "Number of shards provisioned."
  value       = module.kinesis.shard_count
}

output "stream_arn" {
  description = "ARN of the the Kinesis stream."
  value       = module.kinesis.stream_arn
}
