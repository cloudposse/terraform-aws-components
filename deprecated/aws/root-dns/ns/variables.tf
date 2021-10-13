variable "accounts_enabled" {
  type        = "list"
  description = "Accounts to enable"
  default     = ["dev", "staging", "prod", "testing", "audit"]
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `example`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  default     = "terraform"
  description = "Name  (e.g. `app` or `cluster`)"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name`, and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = ["state"]
  description = "Additional attributes (e.g. `state`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "zone_id" {
  description = "DNS zone to update"
}

variable "ttl" {
  description = "Default TTL for the NS records"
  default     = "30"
}

variable "key" {
  description = "Object in the remote state backend containing the state of `account-dns`"
  default     = "account-dns/terraform.tfstate"
}

variable "account" {
  description = "If set, then it will be used instead of 'stage' to assume role. This is useful when you need another domain for existing stage"
  type        = "string"
  default     = ""
}
