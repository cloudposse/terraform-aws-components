variable "loki_component_name" {
  type        = string
  description = "The name of the loki component"
  default     = "eks/loki"
}

variable "loki_stage_name" {
  type        = string
  description = "The stage where the loki component is deployed"
  default     = ""
}

variable "loki_environment_name" {
  type        = string
  description = "The environment where the loki component is deployed"
  default     = ""
}

variable "loki_tenant_name" {
  type        = string
  description = "The tenant where the loki component is deployed"
  default     = ""
}

module "loki" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.loki_component_name

  stage       = length(var.loki_stage_name) > 0 ? var.loki_stage_name : module.this.stage
  environment = length(var.loki_environment_name) > 0 ? var.loki_environment_name : module.this.environment
  tenant      = length(var.loki_tenant_name) > 0 ? var.loki_tenant_name : module.this.tenant

  context = module.this.context
}
