locals {
  enabled = module.this.enabled
  version = local.enabled ? var.release_version : null

  lambdas = local.enabled ? {
    webhook = {
      name = "webhook.zip"
      tag  = local.version
    },
    runners = {
      name = "runners.zip"
      tag  = local.version
    },
    runner-binaries-syncer = {
      name = "runner-binaries-syncer.zip"
      tag  = local.version
    }
  } : {}
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

module "module_artifact" {
  for_each = local.lambdas

  source  = "cloudposse/module-artifact/external"
  version = "0.8.0"

  filename       = each.value.name
  module_name    = module.this.name
  url            = "https://github.com/philips-labs/terraform-aws-github-runner/releases/download/${each.value.tag}/${each.key}.zip"
  curl_arguments = ["-fsSL"]

  module_path = path.module

  context = module.this.context
}

module "github_runner" {
  count = local.enabled ? 1 : 0

  source  = "philips-labs/github-runner/aws"
  version = "5.4.2"

  depends_on = [module.module_artifact]

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
  ssm_paths                               = var.ssm_paths
  instance_target_capacity_type           = var.instance_target_capacity_type
  create_service_linked_role_spot         = var.create_service_linked_role_spot
  enable_fifo_build_queue                 = true
  scale_up_reserved_concurrent_executions = var.scale_up_reserved_concurrent_executions

  enable_user_data_debug_logging_runner = true

  # this variable is substituted in the user-data.sh startup script. It cannot point to another script if using a base ami.
  # instead this will just run after the runner is installed. Hence we use `file` to read the contents of the file which is injected into the user-data.sh
  userdata_post_install = file("${path.module}/templates/userdata_post_install.sh")
  userdata_pre_install  = file("${path.module}/templates/userdata_pre_install.sh")

  runner_extra_labels = var.runner_extra_labels

  tags = module.this.tags
}

module "webhook_github_app" {
  count   = local.enabled && var.enable_update_github_app_webhook ? 1 : 0
  source  = "philips-labs/github-runner/aws//modules/webhook-github-app"
  version = "5.4.2"

  depends_on = [module.github_runner]

  github_app = {
    key_base64     = module.store_read[0].map[var.github_app_key_ssm_path]
    id             = module.store_read[0].map[var.github_app_id_ssm_path]
    webhook_secret = random_id.webhook_secret.hex
  }
  webhook_endpoint = one(module.github_runner[*].webhook.endpoint)
}
