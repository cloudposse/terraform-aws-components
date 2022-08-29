## Generic non company specific locals
locals {
  enabled = module.this.enabled

  service_container = lookup(var.containers, "service")
  # Get the first containerPort in var.container["service"]["port_mappings"]
  container_port = lookup(local.service_container, "port_mappings")[0].containerPort

  assign_public_ip = lookup(var.task, "assign_public_ip", false)

  container_definition = [
    for container in module.container_definition :
    container.json_map_object
  ]

  role_name = format("%s-%s-%s-%s-%s-role", var.namespace, var.tenant, var.environment, var.stage, var.name)

  kinesis_kms_id = try(one(data.aws_kms_alias.selected[*].id), null)
}

module "logs" {
  source  = "cloudposse/cloudwatch-logs/aws"
  version = "0.6.6"

  stream_names      = lookup(var.logs, "stream_names", [])
  retention_in_days = lookup(var.logs, "retention_in_days", 90)

  principals = merge({
    Service = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
  }, lookup(var.logs, "principals", {}))

  additional_permissions = concat([
    "logs:CreateLogStream",
    "logs:DeleteLogStream",
  ], lookup(var.logs, "additional_permissions", []))

  context = module.this.context
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  for_each = var.containers

  container_name = lookup(each.value, "name")

  container_image = lookup(each.value, "ecr_image", null) != null ? format(
    "%s.dkr.ecr.%s.amazonaws.com/%s",
    module.iam_roles.account_map.full_account_map[var.ecr_stage_name],
    coalesce(var.ecr_region, var.region),
    lookup(each.value, "ecr_image", null),
  ) : lookup(each.value, "image")

  container_memory             = lookup(each.value, "memory", null)
  container_memory_reservation = lookup(each.value, "memory_reservation", null)
  container_cpu                = lookup(each.value, "cpu", null)
  essential                    = lookup(each.value, "essential", true)
  readonly_root_filesystem     = lookup(each.value, "readonly_root_filesystem", null)

  map_environment = lookup(each.value, "map_environment", null) != null ? merge(
    lookup(each.value, "map_environment", {}),
    { "APP_ENV" = format("%s-%s-%s-%s", var.namespace, var.tenant, var.environment, var.stage) },
    { "RUNTIME_ENV" = format("%s-%s-%s", var.namespace, var.tenant, var.stage) },
    { "CLUSTER_NAME" = try(one(data.aws_ecs_cluster.selected[*].cluster_name), null) }
  ) : null

  map_secrets = lookup(each.value, "map_secrets", null) != null ? zipmap(
    keys(lookup(each.value, "map_secrets", null)),
    formatlist("%s/%s", format("arn:aws:ssm:%s:%s:parameter",
      coalesce(var.ecr_region, var.region), module.iam_roles.account_map.full_account_map[format("%s-%s", var.tenant, var.stage)]),
    values(lookup(each.value, "map_secrets", null)))
  ) : null
  port_mappings = lookup(each.value, "port_mappings", [])
  command       = lookup(each.value, "command", null)
  entrypoint    = lookup(each.value, "entrypoint", null)
  healthcheck   = lookup(each.value, "healthcheck", null)
  ulimits       = lookup(each.value, "ulimits", null)
  volumes_from  = lookup(each.value, "volumes_from", null)

  log_configuration = lookup(each.value["log_configuration"], "logDriver", {}) == "awslogs" ? merge(lookup(each.value, "log_configuration", {}), {
    options = {
      "awslogs-region"        = var.region
      "awslogs-group"         = module.logs.log_group_name
      "awslogs-stream-prefix" = var.name
    }
  }) : lookup(each.value, "log_configuration", {})
  firelens_configuration = lookup(each.value, "firelens_configuration", null)

  # escape hatch for anything not specifically described above or unsupported by the upstream module
  container_definition = lookup(each.value, "container_definition", {})
}

module "ecs_alb_service_task" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.66.0"

  count = var.enabled ? 1 : 0

  ecs_cluster_arn = local.ecs_cluster_arn
  vpc_id          = local.vpc_id
  subnet_ids      = local.subnet_ids

  container_definition_json = jsonencode(local.container_definition)

  # This is set to true to allow ingress from the ALB sg
  use_alb_security_group = lookup(var.task, "use_alb_security_group", true)
  container_port         = local.container_port
  alb_security_group     = local.lb_sg_id
  security_group_ids     = compact([local.vpc_sg_id, local.rds_sg_id])

  # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#load_balancer
  ecs_load_balancers = var.use_lb ? [
    {
      container_name   = lookup(local.service_container, "name"),
      container_port   = local.container_port,
      target_group_arn = module.alb_ingress[0].target_group_arn
      # not required since elb is unused but must be set to null
      elb_name = null
    },
  ] : []

  assign_public_ip                   = local.assign_public_ip
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
  task_policy_arns                   = tolist(aws_iam_policy.default[*].arn)
  ecs_service_enabled                = lookup(var.task, "ecs_service_enabled", true)


  context = module.this.context
}

# This resource is used instead of the ecs_alb_service_task module's `var.task_policy_arns` because
# the upstream module uses a "count" instead of a "for_each"
#
# See https://github.com/cloudposse/terraform-aws-ecs-alb-service-task/issues/167
resource "aws_iam_role_policy_attachment" "task" {
  for_each = local.enabled && length(var.task_policy_arns) > 0 ? toset(var.task_policy_arns) : toset([])

  policy_arn = each.value
  role       = try(one(module.ecs_alb_service_task[*].task_role_name), null)
}


module "alb_ecs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0" # requires Terraform >= 0.13.0

  namespace   = ""
  environment = ""
  tenant      = ""
  stage       = ""

  context = module.this.context
}

module "alb_ingress" {
  source  = "cloudposse/alb-ingress/aws"
  version = "0.24.3"

  count = var.use_lb ? 1 : 0

  target_group_name = module.alb_ecs_label.id

  vpc_id                        = local.vpc_id
  unauthenticated_listener_arns = [local.lb_listener_https_arn]
  unauthenticated_hosts         = [local.full_domain]
  unauthenticated_priority      = 0
  default_target_group_enabled  = true
  health_check_matcher          = "200-404"

  context = module.this.context
}

data "aws_iam_policy_document" "this" {
  count = var.iam_policy_enabled ? 1 : 0

  dynamic "statement" {
    # Only flatten if a list(string) is passed in, otherwise use the map var as-is
    for_each = try(flatten(var.iam_policy_statements), var.iam_policy_statements)

    content {
      sid    = lookup(statement.value, "sid", statement.key)
      effect = lookup(statement.value, "effect", null)

      actions     = lookup(statement.value, "actions", null)
      not_actions = lookup(statement.value, "not_actions", null)

      resources     = lookup(statement.value, "resources", null)
      not_resources = lookup(statement.value, "not_resources", null)

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = lookup(statement.value, "not_principals", [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = lookup(statement.value, "conditions", [])

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_policy" "default" {
  count    = local.enabled && var.iam_policy_enabled ? 1 : 0
  policy   = join("", data.aws_iam_policy_document.this.*.json)
  tags_all = module.this.tags
}

module "vanity_alias" {
  source  = "cloudposse/route53-alias/aws"
  version = "0.13.0"

  aliases         = var.vanity_alias
  parent_zone_id  = local.vanity_domain_zone_id
  target_dns_name = local.lb_name
  target_zone_id  = local.lb_zone_id

  context = module.this.context
}

module "ecs_cloudwatch_autoscaling" {
  source  = "cloudposse/ecs-cloudwatch-autoscaling/aws"
  version = "0.7.3"

  count = var.task_enabled ? 1 : 0

  service_name          = module.ecs_alb_service_task[0].service_name
  cluster_name          = try(one(data.aws_ecs_cluster.selected[*].cluster_name), null)
  min_capacity          = lookup(var.task, "min_capacity", 1)
  max_capacity          = lookup(var.task, "max_capacity", 2)
  scale_up_adjustment   = 1
  scale_up_cooldown     = 60
  scale_down_adjustment = -1
  scale_down_cooldown   = 300

  context = module.this.context

  depends_on = [
    module.ecs_alb_service_task[0].service_arn
  ]
}

resource "aws_kinesis_stream" "default" {
  count               = local.enabled && var.kinesis_enabled ? 1 : 0
  name                = format("%s-%s", module.this.id, "kinesis-stream")
  shard_count         = var.shard_count
  retention_period    = var.retention_period
  shard_level_metrics = var.shard_level_metrics
  stream_mode_details {
    stream_mode = var.stream_mode
  }
  encryption_type = "KMS"
  kms_key_id      = local.kinesis_kms_id != null ? local.kinesis_kms_id : "alias/aws/kinesis"
  tags            = module.this.tags

  lifecycle {
    ignore_changes = [
      stream_mode_details
    ]
  }
}
