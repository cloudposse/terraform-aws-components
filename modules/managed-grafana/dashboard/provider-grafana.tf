variable "grafana_component_name" {
  type        = string
  description = "The name of the component used to provision an Amazon Managed Grafana workspace"
  default     = "managed-grafana/workspace"
}

variable "grafana_api_key_component_name" {
  type        = string
  description = "The name of the component used to provision an Amazon Managed Grafana API key"
  default     = "managed-grafana/api-key"
}

module "grafana" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.grafana_component_name

  context = module.this.context
}

module "grafana_api_key" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.grafana_api_key_component_name

  context = module.this.context
}

data "aws_ssm_parameter" "grafana_api_key" {
  name = module.grafana_api_key.outputs.ssm_path_grafana_api_key
}

provider "grafana" {
  url  = format("https://%s/", module.grafana.outputs.workspace_endpoint)
  auth = data.aws_ssm_parameter.grafana_api_key.value
}
