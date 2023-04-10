locals {
  enabled = module.this.enabled
}

data "aws_msk_cluster" "default" {
  cluster_name = module.msk_cluster.outputs.cluster_name
}

provider "kafka" {
  bootstrap_servers = split(",", data.aws_msk_cluster.default.bootstrap_brokers_tls)
}

resource "kafka_topic" "default" {
  for_each = local.enabled ? var.kafka_topics : {}

  name               = each.key
  replication_factor = each.value.replication_factor
  partitions         = each.value.partitions
  config             = each.value.config
}
