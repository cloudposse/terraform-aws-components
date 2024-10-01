locals {
  enabled = module.this.enabled
}

resource "aws_service_discovery_private_dns_namespace" "default" {
  count       = local.enabled && var.type == "private" ? 1 : 0
  name        = module.this.id
  description = var.description
  vpc         = module.vpc.outputs.vpc_id
}

resource "aws_service_discovery_public_dns_namespace" "default" {
  count       = local.enabled && var.type == "public" ? 1 : 0
  name        = module.this.id
  description = var.description
}

resource "aws_service_discovery_http_namespace" "default" {
  count       = local.enabled && var.type == "http" ? 1 : 0
  name        = module.this.id
  description = var.description
}
