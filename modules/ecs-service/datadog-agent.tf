variable "datadog_agent_sidecar_enabled" {
  type        = bool
  default     = false
  description = "Enable the Datadog Agent Sidecar"
}

variable "datadog_log_method_is_firelens" {
  type        = bool
  default     = false
  description = "Datadog logs can be sent via cloudwatch logs (and lambda) or firelens, set this to true to enable firelens via a sidecar container for fluentbit"
}

variable "datadog_sidecar_containers_logs_enabled" {
  type        = bool
  default     = true
  description = "Enable the Datadog Agent Sidecar to send logs to aws cloudwatch group, requires `datadog_agent_sidecar_enabled` to be true"
}

variable "datadog_logging_tags" {
  type        = map(string)
  default     = null
  description = "Tags to add to all logs sent to Datadog"
}

variable "datadog_logging_default_tags_enabled" {
  type        = bool
  default     = true
  description = "Add Default tags to all logs sent to Datadog"
}

locals {
  default_datadog_tags = var.datadog_logging_default_tags_enabled ? {
    env     = module.this.stage
    account = format("%s-%s-%s", module.this.tenant, module.this.environment, module.this.stage)
  } : null

  all_dd_tags = join(",", [for k, v in merge(local.default_datadog_tags, var.datadog_logging_tags) : format("%s:%s", k, v)])

  datadog_logconfiguration_firelens = {
    logDriver = "awsfirelens"
    options = var.datadog_agent_sidecar_enabled ? {
      Name           = "datadog",
      apikey         = one(module.datadog_configuration[*].datadog_app_key),
      Host           = format("http-intake.logs.%s", one(module.datadog_configuration[*].datadog_site))
      dd_service     = module.this.name,
      dd_tags        = local.all_dd_tags,
      dd_source      = "ecs",
      dd_message_key = "log",
      TLS            = "on",
      provider       = "ecs"
    } : {}
  }
}

module "datadog_sidecar_logs" {
  source  = "cloudposse/cloudwatch-logs/aws"
  version = "0.6.6"

  # if we are using datadog firelens we don't need to create a log group
  count = local.enabled && var.datadog_agent_sidecar_enabled && var.datadog_sidecar_containers_logs_enabled ? 1 : 0

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

module "datadog_container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  count = local.enabled && var.datadog_agent_sidecar_enabled ? 1 : 0

  container_cpu    = 256
  container_memory = 512
  container_name   = "datadog-agent"
  container_image  = "public.ecr.aws/datadog/agent:latest"
  essential        = true
  map_environment = {
    "ECS_FARGATE"                          = var.task.launch_type == "FARGATE" ? true : false
    "DD_API_KEY"                           = one(module.datadog_configuration[*].datadog_api_key)
    "DD_SITE"                              = one(module.datadog_configuration[*].datadog_site)
    "DD_ENV"                               = module.this.stage
    "DD_LOGS_ENABLED"                      = true
    "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL" = true
    "SD_BACKEND"                           = "docker"
    "DD_PROCESS_AGENT_ENABLED"             = true
    "DD_DOGSTATSD_NON_LOCAL_TRAFFIC"       = true
    "DD_APM_ENABLED"                       = true
    "DD_CONTAINER_LABELS_AS_TAGS" = jsonencode({
      "org.opencontainers.image.revision" = "version"
    })
  }

  // Datadog DogStatsD/tracing ports
  port_mappings = [{
    containerPort = 8125
    hostPort      = 8125
    protocol      = "udp"
    }, {
    containerPort = 8126
    hostPort      = 8126
    protocol      = "tcp"
  }]

  log_configuration = var.datadog_sidecar_containers_logs_enabled ? {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = one(module.datadog_sidecar_logs[*].log_group_name)
      "awslogs-region"        = var.region
      "awslogs-stream-prefix" = "datadog-agent"
    }
  } : null
}

module "datadog_fluent_bit_container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  count = local.enabled && var.datadog_agent_sidecar_enabled ? 1 : 0

  container_cpu    = 256
  container_memory = 512
  container_name   = "datadog-log-router"
  # From Datadog Support:
  # In this case, the newest container image with the latest tag (corresponding to version 2.29.0) looks like it is crashing for certain customers, which is causing the Task to deprovision.
  # Note: We recommend customers to use the stable tag for this type of reason
  container_image = "amazon/aws-for-fluent-bit:stable"
  essential       = true
  firelens_configuration = {
    type = "fluentbit"
    options = {
      config-file-type        = "file",
      config-file-value       = "/fluent-bit/configs/parse-json.conf",
      enable-ecs-log-metadata = "true"
    }
  }

  log_configuration = var.datadog_sidecar_containers_logs_enabled ? {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = one(module.datadog_sidecar_logs[*].log_group_name)
      "awslogs-region"        = var.region
      "awslogs-stream-prefix" = "datadog-log-router"
    }
  } : null
}
