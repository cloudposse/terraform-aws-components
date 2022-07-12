locals {
  # Throw an error if lookup fails
  # tflint-ignore: terraform_unused_declarations
  check_required_tags = [
    for k in var.required_tags :
    lookup(module.this.tags, k)
  ]
}

variable "required_tags" {
  type        = list(string)
  description = "List of required tag names"
  default     = []
}
