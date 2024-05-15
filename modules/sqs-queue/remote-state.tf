
module "dead_letter_sqs_remote_state" {
  count = var.dead_letter_sqs_component_name != null ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.dead_letter_sqs_component_name

  context = module.this.context
}
