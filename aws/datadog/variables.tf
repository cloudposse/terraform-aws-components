variable "namespace" {
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "integrations" {
  type        = "list"
  description = "List of AWS integration permissions sets to apply (all, core, rds)"
}
