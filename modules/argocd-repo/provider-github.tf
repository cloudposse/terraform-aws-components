provider "github" {
  base_url = var.github_base_url
  owner    = var.github_organization
  token    = local.github_token
}
