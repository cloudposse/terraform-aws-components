variable "region" {
  type        = string
  description = "AWS Region"
}

variable "s3_bucket_arn" {
  description = "Amazon Resource Name (ARN) of the Lake Formation resource, an S3 path."
  type        = string
}

variable "role_arn" {
  description = "(Optional) Role that has read/write access to the Lake Formation resource. If not provided, the Lake Formation service-linked role must exist and is used."
  type        = string
  default     = null
}

variable "create_service_linked_role" {
  description = "Set to 'true' to create service-linked role for Lake Formation (can only be done once!)"
  type        = bool
  default     = false
}

variable "catalog_id" {
  description = "(Optional) Identifier for the Data Catalog. If not provided, the account ID will be used."
  type        = string
  default     = null
}

variable "admin_arn_list" {
  description = "(Optional) Set of ARNs of AWS Lake Formation principals (IAM users or roles)."
  type        = list(string)
  default     = []
}

variable "trusted_resource_owners" {
  description = "(Optional) List of the resource-owning account IDs that the caller's account can use to share their user access details (user ARNs)."
  type        = list(string)
  default     = []
}

variable "database_default_permissions" {
  description = "(Optional) Up to three configuration blocks of principal permissions for default create database permissions."
  type        = list(map(any))
  default     = []
}

variable "table_default_permissions" {
  description = "(Optional) Up to three configuration blocks of principal permissions for default create table permissions."
  type        = list(map(any))
  default     = []
}

variable "lf_tags" {
  description = "A map of key-value pairs to be used as Lake Formation tags."
  type        = map(list(string))
  default     = {}
}

variable "resources" {
  description = "A map of Lake Formation resources to create, with related attributes."
  type        = map(any)
  default     = {}
}
