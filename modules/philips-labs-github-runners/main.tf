locals {
  enabled     = var.enabled
  version     = var.enabled ? var.release_version : null
  lambda_repo = "https://github.com/philips-labs/terraform-aws-github-runner"

  lambdas = var.enabled ? [
    {
      name = "webhook"
      tag  = local.version
    },
    {
      name = "runners"
      tag  = local.version
    },
    {
      name = "runner-binaries-syncer"
      tag  = local.version
    }
  ] : []
}

module "store_read" {
  count = local.enabled ? 1 : 0

  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.11.0"

  parameter_read = [
    var.github_app_key_ssm_path,
    var.github_app_id_ssm_path
  ]
}

resource "random_id" "webhook_secret" {
  byte_length = 20
}

module "fetch_lambdas" {
  count = local.enabled ? 1 : 0

  source  = "philips-labs/github-runner/aws//modules/download-lambda"
  version = "5.4.0"

  lambdas = local.lambdas
}

module "github_runner" {
  count = local.enabled ? 1 : 0

  source  = "philips-labs/github-runner/aws"
  version = "5.4.0"

  aws_region = var.region
  vpc_id     = module.vpc.outputs.vpc_id
  subnet_ids = module.vpc.outputs.private_subnet_ids

  github_app = {
    key_base64     = module.store_read[0].map[var.github_app_key_ssm_path]
    id             = module.store_read[0].map[var.github_app_id_ssm_path]
    webhook_secret = random_id.webhook_secret.hex
  }

  # here we hardcode the names of the lambda zips because they always have the same name,
  # the output of the fetch lambdas module is a list of zip names, which we cannot be certain will have the same order.
  webhook_lambda_zip                = "webhook.zip"
  runner_binaries_syncer_lambda_zip = "runner-binaries-syncer.zip"
  runners_lambda_zip                = "runners.zip"

  enable_organization_runners             = true
  enable_ssm_on_runners                   = true
  create_service_linked_role_spot         = true
  enable_fifo_build_queue                 = true
  scale_up_reserved_concurrent_executions = var.scale_up_reserved_concurrent_executions

  enable_user_data_debug_logging_runner = true

  # this variable is substituted in the user-data.sh startup script. It cannot point to another script if using a base ami.
  # instead this will just run after the runner is installed. Hence we use `file` to read the contents of the file which is injected into the user-data.sh
  userdata_post_install = file("${path.module}/templates/userdata_post_install.sh")

  runner_extra_labels = var.runner_extra_labels

  tags = module.this.tags
}

module "webhook_github_app" {
  count = local.enabled && var.enable_update_github_app_webhook ? 1 : 0
  ## See README.md for more info on why we use this source instead of:
  # source = "philips-labs/github-runner/aws//modules/webhook-github-app"
  # version = "5.4.0"
  source = "./modules/webhook-github-app"

  depends_on = [module.github_runner]

  github_app = {
    key_base64     = module.store_read[0].map[var.github_app_key_ssm_path]
    id             = module.store_read[0].map[var.github_app_id_ssm_path]
    webhook_secret = random_id.webhook_secret.hex
  }
  webhook_endpoint = one(module.github_runner[*].webhook.endpoint)
}
