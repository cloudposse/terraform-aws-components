locals {
  enabled = module.this.enabled

  glue_iam_role_arn  = module.glue_iam_role.outputs.role_arn
  glue_iam_role_name = module.glue_iam_role.outputs.role_name

  command = var.command != null ? var.command : {
    name            = var.glue_job_command_name
    script_location = format("s3://%s/%s", module.glue_job_s3_bucket.outputs.bucket_id, var.glue_job_s3_bucket_script_path)
    python_version  = var.glue_job_command_python_version
  }
}

module "glue_job" {
  source  = "cloudposse/glue/aws//modules/glue-job"
  version = "0.4.0"

  job_name                  = var.job_name
  job_description           = var.job_description
  role_arn                  = local.glue_iam_role_arn
  connections               = var.connections
  glue_version              = var.glue_version
  default_arguments         = var.default_arguments
  non_overridable_arguments = var.non_overridable_arguments
  security_configuration    = var.security_configuration
  timeout                   = var.timeout
  max_capacity              = var.max_capacity
  max_retries               = var.max_retries
  worker_type               = var.worker_type
  number_of_workers         = var.number_of_workers
  command                   = local.command
  execution_property        = var.execution_property
  notification_property     = var.notification_property

  context = module.this.context
}
