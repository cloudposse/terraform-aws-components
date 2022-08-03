locals {
  # Throw an error if lookup fails
  # tflint-ignore: terraform_unused_declarations
  check_required_tags = module.this.enabled ? [
    for k in var.required_tags :
    lookup(module.this.tags, k)
  ] : []
}

variable "required_tags" {
  type        = list(string)
  description = "List of required tag names"
  default     = []
}

# introspection module will contain the additional tags
module "introspection" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  tags = merge(var.tags, {
    "Component" = basename(abspath(path.module))
  })

  context = module.this.context
}
