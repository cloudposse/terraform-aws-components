locals {
  enabled = module.this.enabled

  vpc_outputs        = module.vpc.outputs
  private_subnet_ids = slice(local.vpc_outputs.private_subnet_ids, 0, 2) # MWAA Environments must have length less than or equal to 2 subnets
  vpc_id             = local.vpc_outputs.vpc_id

  allowed_cidr_blocks = concat(
    var.allowed_cidr_blocks,
    [
      for k in keys(module.vpc_ingress) :
      module.vpc_ingress[k].outputs.vpc_cidr
    ]
  )
}

module "mwaa_environment" {
  source  = "cloudposse/mwaa/aws"
  version = "0.4.8"

  region                          = var.region
  create_s3_bucket                = var.create_s3_bucket
  create_iam_role                 = var.create_iam_role
  source_bucket_arn               = var.source_bucket_arn
  execution_role_arn              = var.execution_role_arn
  min_workers                     = var.min_workers
  max_workers                     = var.max_workers
  webserver_access_mode           = var.webserver_access_mode
  airflow_version                 = var.airflow_version
  vpc_id                          = local.vpc_id
  subnet_ids                      = local.private_subnet_ids
  dag_s3_path                     = var.dag_s3_path
  dag_processing_logs_enabled     = var.dag_processing_logs_enabled
  dag_processing_logs_level       = var.dag_processing_logs_level
  scheduler_logs_enabled          = var.scheduler_logs_enabled
  scheduler_logs_level            = var.scheduler_logs_level
  task_logs_enabled               = var.task_logs_enabled
  task_logs_level                 = var.task_logs_level
  webserver_logs_enabled          = var.webserver_logs_enabled
  webserver_logs_level            = var.webserver_logs_level
  worker_logs_enabled             = var.worker_logs_enabled
  worker_logs_level               = var.worker_logs_level
  environment_class               = var.environment_class
  plugins_s3_object_version       = var.plugins_s3_object_version
  plugins_s3_path                 = var.plugins_s3_path
  requirements_s3_object_version  = var.requirements_s3_object_version
  requirements_s3_path            = var.requirements_s3_path
  weekly_maintenance_window_start = var.weekly_maintenance_window_start
  allowed_cidr_blocks             = local.allowed_cidr_blocks
  allowed_security_group_ids      = var.allowed_security_groups
  airflow_configuration_options   = var.airflow_configuration_options

  context = module.this.context
}
