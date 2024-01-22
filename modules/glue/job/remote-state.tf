module "glue_iam_role" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.glue_iam_component_name

  context = module.this.context
}

module "glue_job_s3_bucket" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.glue_job_s3_bucket_component_name
  bypass    = var.glue_job_s3_bucket_component_name == null

  defaults = {
    bucket_id                   = null
    bucket_arn                  = null
    bucket_domain_name          = null
    bucket_regional_domain_name = null
    bucket_region               = null
  }

  context = module.this.context
}
