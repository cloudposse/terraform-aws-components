module "glue_workflow" {
  source  = "cloudposse/glue/aws//modules/glue-workflow"
  version = "0.4.0"

  workflow_name          = var.workflow_name
  workflow_description   = var.workflow_description
  default_run_properties = var.default_run_properties
  max_concurrent_runs    = var.max_concurrent_runs

  context = module.this.context
}
