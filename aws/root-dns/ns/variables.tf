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

variable "role_arn" {
  description = "The role to be assumed in the subaccount"
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
