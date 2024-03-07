## Generic non company specific locals
locals {
  enabled = module.this.enabled

  s3_mirroring_enabled = local.enabled && try(length(var.s3_mirror_name) > 0, false)

  service_container = lookup(var.containers, "service")
  # Get the first containerPort in var.container["service"]["port_mappings"]
  container_port = try(lookup(local.service_container, "port_mappings")[0].containerPort, null)

  assign_public_ip = lookup(local.task, "assign_public_ip", false)

  container_definition = concat([
    for container in module.container_definition :
    container.json_map_object
    ],
    [
      for container in module.datadog_container_definition :
      container.json_map_object
    ],
    var.datadog_log_method_is_firelens ? [
      for container in module.datadog_fluent_bit_container_definition :
      container.json_map_object
    ] : [],
  )

  kinesis_kms_id = try(one(data.aws_kms_alias.selected[*].id), null)

  use_alb_security_group = local.is_alb ? lookup(local.task, "use_alb_security_group", true) : false

  task_definition_s3_key     = format("%s/%s/task-definition.json", module.ecs_cluster.outputs.cluster_name, module.this.id)
  task_definition_use_s3     = local.enabled && local.s3_mirroring_enabled && contains(flatten(data.aws_s3_objects.mirror[*].keys), local.task_definition_s3_key)
  task_definition_s3_objects = flatten(data.aws_s3_objects.mirror[*].keys)

  task_definition_s3 = try(jsondecode(data.aws_s3_object.task_definition[0].body), {})

  task_s3 = local.task_definition_use_s3 ? {
    launch_type  = try(local.task_definition_s3.requiresCompatibilities[0], null)
    network_mode = lookup(local.task_definition_s3, "networkMode", null)
    task_memory  = try(tonumber(lookup(local.task_definition_s3, "memory")), null)
    task_cpu     = try(tonumber(lookup(local.task_definition_s3, "cpu")), null)
  } : {}

  task = merge(var.task, local.task_s3)

  efs_component_volumes = lookup(local.task, "efs_component_volumes", [])
  efs_component_map = {
    for efs in local.efs_component_volumes : efs["name"] => efs
  }
  efs_component_remote_state = {
    for efs in local.efs_component_volumes : efs["name"] => module.efs[efs["name"]].outputs
  }
  efs_component_merged = [
    for efs_volume_name, efs_component_output in local.efs_component_remote_state : {
      host_path = local.efs_component_map[efs_volume_name].host_path
      name      = efs_volume_name
      efs_volume_configuration = [
        #again this is a hardcoded array because AWS does not support multiple configurations per volume
        {
          file_system_id          = efs_component_output.efs_id
          root_directory          = local.efs_component_map[efs_volume_name].efs_volume_configuration[0].root_directory
          transit_encryption      = local.efs_component_map[efs_volume_name].efs_volume_configuration[0].transit_encryption
          transit_encryption_port = local.efs_component_map[efs_volume_name].efs_volume_configuration[0].transit_encryption_port
          authorization_config    = local.efs_component_map[efs_volume_name].efs_volume_configuration[0].authorization_config
        }
      ]
    }
  ]
  efs_volumes = concat(lookup(local.task, "efs_volumes", []), local.efs_component_merged)
}

data "aws_s3_objects" "mirror" {
  count  = local.s3_mirroring_enabled ? 1 : 0
  bucket = lookup(module.s3[0].outputs, "bucket_id", null)
  prefix = format("%s/%s", module.ecs_cluster.outputs.cluster_name, module.this.id)
}

data "aws_s3_object" "task_definition" {
  count  = local.task_definition_use_s3 ? 1 : 0
  bucket = lookup(module.s3[0].outputs, "bucket_id", null)
  key    = try(element(local.task_definition_s3_objects, index(local.task_definition_s3_objects, local.task_definition_s3_key)), null)
}

module "logs" {
  source  = "cloudposse/cloudwatch-logs/aws"
  version = "0.6.8"

  # if we are using datadog firelens we don't need to create a log group
  count = local.enabled && (!var.datadog_agent_sidecar_enabled || !var.datadog_log_method_is_firelens) ? 1 : 0

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

module "roles_to_principals" {
  source   = "../account-map/modules/roles-to-principals"
  context  = module.this.context
  role_map = {}
}

locals {
  container_chamber = {
    for name, result in data.aws_ssm_parameters_by_path.default :
    name => { for key, value in zipmap(result.names, result.values) : element(reverse(split("/", key)), 0) => value }
  }

  container_aliases = {
    for name, settings in var.containers :
    settings["name"] => name if local.enabled
  }

  container_s3 = {
    for item in lookup(local.task_definition_s3, "containerDefinitions", []) :
    local.container_aliases[item.name] => { container_definition = item }
  }

  containers = {
    for name, settings in var.containers :
    name => merge(settings, local.container_chamber[name], lookup(local.container_s3, name, {}))
    if local.enabled
  }
}

data "aws_ssm_parameters_by_path" "default" {
  for_each = { for k, v in var.containers : k => v if local.enabled }
  path     = format("/%s/%s/%s", var.chamber_service, var.name, each.key)
}

locals {
  containers_envs = merge([
    for name, settings in var.containers :
    { for k, v in lookup(settings, "map_environment", {}) : "${name},${k}" => v if local.enabled }
  ]...)
}


data "template_file" "envs" {
  for_each = { for k, v in local.containers_envs : k => v if local.enabled }

  template = replace(each.value, "$$", "$")

  vars = {
    stage         = module.this.stage
    namespace     = module.this.namespace
    name          = module.this.name
    full_domain   = local.full_domain
    vanity_domain = var.vanity_domain
    # `service_domain` uses whatever the current service is (public/private)
    service_domain         = local.domain_no_service_name
    service_domain_public  = local.public_domain_no_service_name
    service_domain_private = local.private_domain_no_service_name
  }
}

locals {
  env_map_subst = {
    for k, v in data.template_file.envs :
    k => v.rendered
  }
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.61.1"

  for_each = { for k, v in local.containers : k => v if local.enabled }

  container_name = each.value["name"]

  container_image = lookup(each.value, "ecr_image", null) != null ? format(
    "%s.dkr.ecr.%s.amazonaws.com/%s",
    module.roles_to_principals.full_account_map[var.ecr_stage_name],
    coalesce(var.ecr_region, var.region),
    lookup(each.value, "ecr_image", null)
  ) : lookup(each.value, "image")

  container_memory             = each.value["memory"]
  container_memory_reservation = each.value["memory_reservation"]
  container_cpu                = each.value["cpu"]
  essential                    = each.value["essential"]
  readonly_root_filesystem     = each.value["readonly_root_filesystem"]
  mount_points                 = each.value["mount_points"]

  map_environment = lookup(each.value, "map_environment", null) != null ? merge(
    { for k, v in local.env_map_subst : split(",", k)[1] => v if split(",", k)[0] == each.key },
    { "APP_ENV" = format("%s-%s-%s-%s", var.namespace, var.tenant, var.environment, var.stage) },
    { "RUNTIME_ENV" = format("%s-%s-%s", var.namespace, var.tenant, var.stage) },
    { "CLUSTER_NAME" = module.ecs_cluster.outputs.cluster_name },
    var.datadog_agent_sidecar_enabled ? {
      "DD_DOGSTATSD_PORT"      = 8125,
      "DD_TRACING_ENABLED"     = "true",
      "DD_SERVICE_NAME"        = var.name,
      "DD_ENV"                 = var.stage,
      "DD_PROFILING_EXPORTERS" = "agent"
    } : {}
  ) : null

  map_secrets = lookup(each.value, "map_secrets", null) != null ? zipmap(
    keys(lookup(each.value, "map_secrets", null)),
    formatlist("%s/%s", format("arn:aws:ssm:%s:%s:parameter", var.region, module.roles_to_principals.full_account_map[format("%s-%s", var.tenant, var.stage)]),
    values(lookup(each.value, "map_secrets", null)))
  ) : null
  port_mappings        = each.value["port_mappings"]
  command              = each.value["command"]
  entrypoint           = each.value["entrypoint"]
  healthcheck          = each.value["healthcheck"]
  ulimits              = each.value["ulimits"]
  volumes_from         = each.value["volumes_from"]
  docker_labels        = each.value["docker_labels"]
  container_depends_on = each.value["container_depends_on"]
  privileged           = each.value["privileged"]

  log_configuration = lookup(lookup(each.value, "log_configuration", {}), "logDriver", {}) == "awslogs" ? merge(lookup(each.value, "log_configuration", {}), {
    logDriver = "awslogs"
    options = tomap({
      awslogs-region        = var.region,
      awslogs-group         = local.awslogs_group,
      awslogs-stream-prefix = coalesce(each.value["name"], each.key),
    })
    # if we are not using awslogs, we execute this line, which if we have dd enabled, means we are using firelens, so merge that config in.
  }) : merge(lookup(each.value, "log_configuration", {}), local.datadog_logconfiguration_firelens)

  firelens_configuration = lookup(each.value, "firelens_configuration", null)


  # escape hatch for anything not specifically described above or unsupported by the upstream module
  container_definition = lookup(each.value, "container_definition", {})
}

locals {
  awslogs_group           = var.datadog_log_method_is_firelens ? "" : join("", module.logs[*].log_group_name)
  external_security_group = try(module.security_group[*].outputs.security_group_id, [])
}

module "ecs_alb_service_task" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.72.0"

  count = local.enabled ? 1 : 0

  ecs_cluster_arn = local.ecs_cluster_arn
  vpc_id          = local.vpc_id
  subnet_ids      = local.subnet_ids

  container_definition_json = jsonencode(local.container_definition)

  # This is set to true to allow ingress from the ALB sg
  use_alb_security_group = local.use_alb_security_group
  container_port         = local.container_port
  alb_security_group     = local.lb_sg_id
  security_group_ids     = compact(concat([local.vpc_sg_id, local.rds_sg_id], local.external_security_group))

  nlb_cidr_blocks     = local.is_nlb ? [module.vpc.outputs.vpc_cidr] : []
  nlb_container_port  = local.is_nlb ? local.container_port : 80
  use_nlb_cidr_blocks = local.is_nlb

  # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#load_balancer
  ecs_load_balancers = local.use_lb ? [
    {
      container_name   = lookup(local.service_container, "name"),
      container_port   = local.container_port,
      target_group_arn = local.is_alb ? module.alb_ingress[0].target_group_arn : local.nlb.default_target_group_arn
      # not required since elb is unused but must be set to null
      elb_name = null
    },
  ] : []

  assign_public_ip                   = local.assign_public_ip
  ignore_changes_task_definition     = lookup(local.task, "ignore_changes_task_definition", false)
  ignore_changes_desired_count       = lookup(local.task, "ignore_changes_desired_count", true)
  launch_type                        = lookup(local.task, "launch_type", "FARGATE")
  scheduling_strategy                = lookup(local.task, "scheduling_strategy", "REPLICA")
  network_mode                       = lookup(local.task, "network_mode", "awsvpc")
  pid_mode                           = local.task["pid_mode"]
  ipc_mode                           = local.task["ipc_mode"]
  propagate_tags                     = lookup(local.task, "propagate_tags", "SERVICE")
  deployment_minimum_healthy_percent = lookup(local.task, "deployment_minimum_healthy_percent", null)
  deployment_maximum_percent         = lookup(local.task, "deployment_maximum_percent", null)
  deployment_controller_type         = lookup(local.task, "deployment_controller_type", null)
  desired_count                      = lookup(local.task, "desired_count", 0)
  task_memory                        = lookup(local.task, "task_memory", null)
  task_cpu                           = lookup(local.task, "task_cpu", null)
  wait_for_steady_state              = lookup(local.task, "wait_for_steady_state", true)
  circuit_breaker_deployment_enabled = lookup(local.task, "circuit_breaker_deployment_enabled", true)
  circuit_breaker_rollback_enabled   = lookup(local.task, "circuit_breaker_rollback_enabled", true)
  task_policy_arns                   = var.iam_policy_enabled ? concat(var.task_policy_arns, aws_iam_policy.default[*].arn) : var.task_policy_arns
  ecs_service_enabled                = lookup(local.task, "ecs_service_enabled", true)
  task_role_arn                      = lookup(local.task, "task_role_arn", one(module.iam_role[*]["outputs"]["role"]["arn"]))
  capacity_provider_strategies       = lookup(local.task, "capacity_provider_strategies")

  task_exec_policy_arns_map = var.task_exec_policy_arns_map

  efs_volumes        = local.efs_volumes
  docker_volumes     = lookup(local.task, "docker_volumes", [])
  fsx_volumes        = lookup(local.task, "fsx_volumes", [])
  bind_mount_volumes = lookup(local.task, "bind_mount_volumes", [])

  exec_enabled                   = var.exec_enabled
  service_connect_configurations = local.service_connect_configurations
  service_registries             = local.service_discovery

  depends_on = [
    module.alb_ingress
  ]

  context = module.this.context
}

resource "aws_security_group_rule" "custom_sg_rules" {
  for_each = local.enabled && var.custom_security_group_rules != [] ? {
    for sg_rule in var.custom_security_group_rules :
    format("%s_%s_%s", sg_rule.protocol, sg_rule.from_port, sg_rule.to_port) => sg_rule
  } : {}
  description       = each.value.description
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = one(module.ecs_alb_service_task[*].service_security_group_id)
}

module "alb_ingress" {
  source  = "cloudposse/alb-ingress/aws"
  version = "0.28.0"

  count = local.is_alb ? 1 : 0

  vpc_id                        = local.vpc_id
  unauthenticated_listener_arns = [local.lb_listener_https_arn]
  unauthenticated_hosts = var.lb_catch_all ? [format("*.%s", var.vanity_domain), local.full_domain] : concat([
    local.full_domain
  ], var.vanity_alias, var.additional_targets)
  unauthenticated_paths = flatten(var.unauthenticated_paths)
  # When set to catch-all, make priority super high to make sure last to match
  unauthenticated_priority     = var.lb_catch_all ? 99 : var.unauthenticated_priority
  default_target_group_enabled = true

  health_check_matcher             = var.health_check_matcher
  health_check_path                = var.health_check_path
  health_check_port                = var.health_check_port
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  health_check_interval            = var.health_check_interval
  health_check_timeout             = var.health_check_timeout

  stickiness_enabled         = var.stickiness_enabled
  stickiness_type            = var.stickiness_type
  stickiness_cookie_duration = var.stickiness_cookie_duration

  context = module.this.context
}

data "aws_iam_policy_document" "this" {
  count = local.enabled && var.iam_policy_enabled ? 1 : 0

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
  count = local.enabled && var.iam_policy_enabled ? 1 : 0

  name     = format("%s-task-access", module.this.id)
  policy   = join("", data.aws_iam_policy_document.this[*]["json"])
  tags_all = module.this.tags
}

module "vanity_alias" {
  source  = "cloudposse/route53-alias/aws"
  version = "0.13.0"

  count = local.enabled ? 1 : 0

  aliases         = var.vanity_alias
  parent_zone_id  = local.vanity_domain_zone_id
  target_dns_name = local.lb_name
  target_zone_id  = local.lb_zone_id

  context = module.this.context
}

module "ecs_cloudwatch_autoscaling" {
  source  = "cloudposse/ecs-cloudwatch-autoscaling/aws"
  version = "0.7.3"

  count = local.enabled && var.task_enabled && var.autoscaling_enabled ? 1 : 0

  service_name          = module.ecs_alb_service_task[0].service_name
  cluster_name          = module.ecs_cluster.outputs.cluster_name
  min_capacity          = lookup(local.task, "min_capacity", 1)
  max_capacity          = lookup(local.task, "max_capacity", 2)
  scale_up_adjustment   = 1
  scale_up_cooldown     = 60
  scale_down_adjustment = -1
  scale_down_cooldown   = 300

  context = module.this.context

  depends_on = [
    module.ecs_alb_service_task[0].service_arn
  ]
}

locals {
  scale_up_policy_arn   = try(module.ecs_cloudwatch_autoscaling[0].scale_up_policy_arn, "")
  scale_down_policy_arn = try(module.ecs_cloudwatch_autoscaling[0].scale_down_policy_arn, "")

  cpu_utilization_high_alarm_actions    = var.autoscaling_enabled && var.autoscaling_dimension == "cpu" ? local.scale_up_policy_arn : ""
  cpu_utilization_low_alarm_actions     = var.autoscaling_enabled && var.autoscaling_dimension == "cpu" ? local.scale_down_policy_arn : ""
  memory_utilization_high_alarm_actions = var.autoscaling_enabled && var.autoscaling_dimension == "memory" ? local.scale_up_policy_arn : ""
  memory_utilization_low_alarm_actions  = var.autoscaling_enabled && var.autoscaling_dimension == "memory" ? local.scale_down_policy_arn : ""
}

module "ecs_cloudwatch_sns_alarms" {
  source  = "cloudposse/ecs-cloudwatch-sns-alarms/aws"
  version = "0.12.3"
  count   = local.enabled && var.autoscaling_enabled ? 1 : 0

  cluster_name = module.ecs_cluster.outputs.cluster_name
  service_name = module.ecs_alb_service_task[0].service_name

  cpu_utilization_high_threshold          = var.cpu_utilization_high_threshold
  cpu_utilization_high_evaluation_periods = var.cpu_utilization_high_evaluation_periods
  cpu_utilization_high_period             = var.cpu_utilization_high_period

  cpu_utilization_high_alarm_actions = compact(
    concat(
      var.cpu_utilization_high_alarm_actions,
      [local.cpu_utilization_high_alarm_actions],
    )
  )

  cpu_utilization_high_ok_actions = var.cpu_utilization_high_ok_actions

  cpu_utilization_low_threshold          = var.cpu_utilization_low_threshold
  cpu_utilization_low_evaluation_periods = var.cpu_utilization_low_evaluation_periods
  cpu_utilization_low_period             = var.cpu_utilization_low_period

  cpu_utilization_low_alarm_actions = compact(
    concat(
      var.cpu_utilization_low_alarm_actions,
      [local.cpu_utilization_low_alarm_actions],
    )
  )

  cpu_utilization_low_ok_actions = var.cpu_utilization_low_ok_actions

  memory_utilization_high_threshold          = var.memory_utilization_high_threshold
  memory_utilization_high_evaluation_periods = var.memory_utilization_high_evaluation_periods
  memory_utilization_high_period             = var.memory_utilization_high_period

  memory_utilization_high_alarm_actions = compact(
    concat(
      var.memory_utilization_high_alarm_actions,
      [local.memory_utilization_high_alarm_actions],
    )
  )

  memory_utilization_high_ok_actions = var.memory_utilization_high_ok_actions

  memory_utilization_low_threshold          = var.memory_utilization_low_threshold
  memory_utilization_low_evaluation_periods = var.memory_utilization_low_evaluation_periods
  memory_utilization_low_period             = var.memory_utilization_low_period

  memory_utilization_low_alarm_actions = compact(
    concat(
      var.memory_utilization_low_alarm_actions,
      [local.memory_utilization_low_alarm_actions],
    )
  )

  memory_utilization_low_ok_actions = var.memory_utilization_low_ok_actions

  context = module.this.context

  depends_on = [
    module.ecs_alb_service_task
  ]
}

resource "aws_kinesis_stream" "default" {
  count = local.enabled && var.kinesis_enabled ? 1 : 0

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

data "aws_ecs_task_definition" "created_task" {
  task_definition = module.ecs_alb_service_task[0].task_definition_family
}

locals {
  created_task_definition = data.aws_ecs_task_definition.created_task
  task_template = merge(
    {
      containerDefinitions = local.container_definition
      family               = lookup(local.created_task_definition, "family", null),
      taskRoleArn          = lookup(local.created_task_definition, "task_role_arn", null),
      executionRoleArn     = lookup(local.created_task_definition, "execution_role_arn", null),
      networkMode          = lookup(local.created_task_definition, "network_mode", null),
      # we explicitly do not put the volumes here. That should be merged in by GHA
      requiresCompatibilities = [lookup(local.task, "launch_type", "FARGATE")]
      cpu                     = tostring(lookup(local.task, "task_cpu", null))
      memory                  = tostring(lookup(local.task, "task_memory", null))

    }
  )
}

resource "aws_s3_bucket_object" "task_definition_template" {
  count                  = local.s3_mirroring_enabled ? 1 : 0
  bucket                 = lookup(module.s3[0].outputs, "bucket_id", null)
  key                    = format("%s/%s/task-template.json", module.ecs_cluster.outputs.cluster_name, module.this.id)
  content                = jsonencode(local.task_template)
  server_side_encryption = "AES256"
}
