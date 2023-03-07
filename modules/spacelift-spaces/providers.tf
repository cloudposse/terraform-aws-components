variable "spacelift_key_endpoint" {
  default = null
}
variable "spacelift_key_id" {
  default = null
}
variable "spacelift_key_secret" {
  default = null
}

provider "spacelift" {
  api_key_endpoint = var.spacelift_key_endpoint
  api_key_id       = var.spacelift_key_id
  api_key_secret   = var.spacelift_key_secret
}

provider "sops" {}

data "sops_file" "okta_auth" {
  source_file = "./resources/auth.enc.json"
}

variable "okta_provider_organization" {
  type        = string
  description = "This is the org name of your Okta account, for example dev-123456.oktapreview.com would have an org name of dev-123456."
}

variable "okta_provider_base_url" {
  type        = string
  description = "This is the domain of your Okta account, for example dev-123456.oktapreview.com would have a base url of oktapreview.com"
}

variable "okta_url" {
  type        = string
  description = "Okta URL used by users and applications to reach Okta"
}

provider "okta" {
  org_name    = var.okta_provider_organization
  base_url    = var.okta_provider_base_url
  api_token   = lookup(data.sops_file.okta_auth.data, "API_TOKEN", null)
  client_id   = lookup(data.sops_file.okta_auth.data, "CLIENT_ID", null)
  scopes      = try(toset(split(",", data.sops_file.okta_auth.data["SCOPES"])), null)
  private_key = lookup(data.sops_file.okta_auth.data, "PRIVATE_KEY", null)
}
