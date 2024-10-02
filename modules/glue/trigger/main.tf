locals {
  actions = var.actions != null ? var.actions : [
    {
      job_name = module.glue_job.outputs.job_name
      # The job run timeout in minutes. It overrides the timeout value of the job
      timeout = var.glue_job_timeout
    }
  ]
}

module "glue_trigger" {
  source  = "cloudposse/glue/aws//modules/glue-trigger"
  version = "0.4.0"

  trigger_name             = var.trigger_name
  trigger_description      = var.trigger_description
  workflow_name            = module.glue_workflow.outputs.workflow_name
  type                     = var.type
  actions                  = local.actions
  predicate                = var.predicate
  event_batching_condition = var.event_batching_condition
  schedule                 = var.schedule
  trigger_enabled          = var.trigger_enabled
  start_on_creation        = var.start_on_creation

  context = module.this.context
}
