// Service Connect

module "cloudmap_namespace" {
  for_each = { for service_connect in var.service_connect_configurations : service_connect.namespace => service_connect }

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = each.key

  # we ignore errors because the namespace may be a name or an arn of a namespace for the service.
  ignore_errors = true
  context       = module.this.context
}

locals {
  valid_cloudmap_namespaces      = { for k, v in module.cloudmap_namespace : k => v if v.outputs != null }
  service_connect_configurations = [for service_connect in var.service_connect_configurations : merge(service_connect, { namespace = try(local.valid_cloudmap_namespaces[service_connect.namespace].outputs.name, service_connect.namespace) })]
}
// ------------------------------

// Service Discovery

module "cloudmap_namespace_service_discovery" {
  for_each = { for service_connect in var.service_registries : service_connect.namespace => service_connect }

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = each.key

  # we ignore errors because the namespace may be a name or an arn of a namespace for the service.
  ignore_errors = true
  context       = module.this.context
}

locals {
  valid_cloudmap_service_discovery_namespaces = { for k, v in module.cloudmap_namespace_service_discovery : k => v if v.outputs != null }
  service_discovery_configurations            = [for service_registry in var.service_registries : merge(service_registry, { namespace = try(local.valid_cloudmap_service_discovery_namespaces[service_registry.namespace].outputs.name, service_registry.namespace) })]
  service_config_with_id                      = { for service_registry in var.service_registries : service_registry.namespace => merge(service_registry, { id = try(local.valid_cloudmap_service_discovery_namespaces[service_registry.namespace].outputs.id, null) }) }
  service_discovery = [for value in var.service_registries : merge(value, {
    registry_arn = aws_service_discovery_service.default[value.namespace].arn
  })]
}

resource "aws_service_discovery_service" "default" {
  for_each = local.service_config_with_id
  name     = module.this.name

  dns_config {
    namespace_id = each.value.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

// ------------------------------
