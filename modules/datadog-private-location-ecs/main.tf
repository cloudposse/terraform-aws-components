locals {
  enabled = module.this.enabled

  container_definition = concat([
    for container in module.container_definition :
    container.json_map_object
    ],
  )
  datadog_location_config = try(jsondecode(datadog_synthetics_private_location.private_location[0].config), null)

}

module "roles_to_principals" {
  source   = "../account-map/modules/roles-to-principals"
  context  = module.this.context
  role_map = {}
}

resource "datadog_synthetics_private_location" "private_location" {
  count = local.enabled ? 1 : 0

  name        = module.this.id
  description = coalesce(var.private_location_description, format("Private location for %s", module.this.id))
  tags        = module.datadog_configuration.datadog_tags
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  depends_on = [datadog_synthetics_private_location.private_location]

  for_each = { for k, v in var.containers : k => v if local.enabled }

  container_name = lookup(each.value, "name")

  container_image = lookup(each.value, "image")

  container_memory             = lookup(each.value, "memory", null)
  container_memory_reservation = lookup(each.value, "memory_reservation", null)
  container_cpu                = lookup(each.value, "cpu", null)
  essential                    = lookup(each.value, "essential", true)
  readonly_root_filesystem     = lookup(each.value, "readonly_root_filesystem", null)

  map_environment = merge(
    lookup(each.value, "map_environment", {}),
    { "APP_ENV" = format("%s-%s-%s-%s", var.namespace, var.tenant, var.environment, var.stage) },
    { "RUNTIME_ENV" = format("%s-%s-%s", var.namespace, var.tenant, var.stage) },
    { "CLUSTER_NAME" = module.ecs_cluster.outputs.cluster_name },
    { "DATADOG_SITE" = module.datadog_configuration.datadog_site },
    { "DATADOG_API_KEY" = module.datadog_configuration.datadog_api_key },
    { "DATADOG_ACCESS_KEY" = local.datadog_location_config.accessKey },
    { "DATADOG_SECRET_ACCESS_KEY" = local.datadog_location_config.secretAccessKey },
    { "DATADOG_PUBLIC_KEY_PEM" = local.datadog_location_config.publicKey.pem },
    { "DATADOG_PUBLIC_KEY_FINGERPRINT" = local.datadog_location_config.publicKey.fingerprint },
    { "DATADOG_PRIVATE_KEY" = local.datadog_location_config.privateKey },
    { "DATADOG_LOCATION_ID" = local.datadog_location_config.id },
  )

  map_secrets = lookup(each.value, "map_secrets", null) != null ? zipmap(
    keys(lookup(each.value, "map_secrets", null)),
    formatlist("%s/%s", format("arn:aws:ssm:%s:%s:parameter",
      var.region, module.roles_to_principals.full_account_map[format("%s-%s", var.tenant, var.stage)]),
    values(lookup(each.value, "map_secrets", null)))
  ) : null
  port_mappings = lookup(each.value, "port_mappings", [])
  command       = lookup(each.value, "command", null)
  entrypoint    = lookup(each.value, "entrypoint", null)
  healthcheck   = lookup(each.value, "healthcheck", null)
  ulimits       = lookup(each.value, "ulimits", null)
  volumes_from  = lookup(each.value, "volumes_from", null)
  docker_labels = lookup(each.value, "docker_labels", null)

  firelens_configuration = lookup(each.value, "firelens_configuration", null)

  # escape hatch for anything not specifically described above or unsupported by the upstream module
  container_definition = lookup(each.value, "container_definition", {})
}

module "ecs_alb_service_task" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.66.2"

  count = var.enabled ? 1 : 0

  ecs_cluster_arn = local.ecs_cluster_arn
  vpc_id          = local.vpc_id
  subnet_ids      = local.subnet_ids

  container_definition_json = jsonencode(local.container_definition)

  # This is set to true to allow ingress from the ALB sg
  use_alb_security_group = lookup(var.task, "use_alb_security_group", true)
  alb_security_group     = local.lb_sg_id
  security_group_ids     = [local.vpc_sg_id]

  # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#load_balancer
  ecs_load_balancers = []

  assign_public_ip                   = false
  ignore_changes_task_definition     = lookup(var.task, "ignore_changes_task_definition", false)
  ignore_changes_desired_count       = lookup(var.task, "ignore_changes_desired_count", true)
  launch_type                        = lookup(var.task, "launch_type", "FARGATE")
  network_mode                       = lookup(var.task, "network_mode", "awsvpc")
  propagate_tags                     = lookup(var.task, "propagate_tags", "SERVICE")
  deployment_minimum_healthy_percent = lookup(var.task, "deployment_minimum_healthy_percent", null)
  deployment_maximum_percent         = lookup(var.task, "deployment_maximum_percent", null)
  deployment_controller_type         = lookup(var.task, "deployment_controller_type", null)
  desired_count                      = lookup(var.task, "desired_count", 0)
  task_memory                        = lookup(var.task, "task_memory", null)
  task_cpu                           = lookup(var.task, "task_cpu", null)
  wait_for_steady_state              = lookup(var.task, "wait_for_steady_state", true)
  circuit_breaker_deployment_enabled = lookup(var.task, "circuit_breaker_deployment_enabled", true)
  circuit_breaker_rollback_enabled   = lookup(var.task, "circuit_breaker_rollback_enabled  ", true)
  task_policy_arns                   = []
  ecs_service_enabled                = lookup(var.task, "ecs_service_enabled", true)
  capacity_provider_strategies       = lookup(var.task, "capacity_provider_strategies", [])

  context = module.this.context
}
