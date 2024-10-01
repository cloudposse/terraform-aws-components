module "glue_workflow" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.glue_workflow_component_name
  bypass    = var.glue_workflow_component_name == null

  defaults = {
    workflow_id   = null
    workflow_name = null
    workflow_arn  = null
  }

  context = module.this.context
}

module "glue_job" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.glue_job_component_name
  bypass    = var.glue_job_component_name == null

  defaults = {
    job_id   = null
    job_name = null
    job_arn  = null
  }

  context = module.this.context
}
