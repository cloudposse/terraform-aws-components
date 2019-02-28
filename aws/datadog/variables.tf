variable "namespace" {
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "integrations" {
  type        = "list"
  description = "List of integration names with permissions to apply (`all`, `core`, `rds`)"
}
