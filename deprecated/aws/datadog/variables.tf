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

variable "chamber_service" {
  # Actually defaults to the name of the directory this is in:  basename(pathexpand(path.module)
  default     = ""
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "chamber_parameter_name" {
  default     = "/%s/%s"
  description = "String format for combining chamber_service with parameter name"
}
