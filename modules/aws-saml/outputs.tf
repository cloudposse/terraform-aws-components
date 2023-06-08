output "saml_provider_arns" {
  value = {
    for key, value in var.saml_providers : key => aws_iam_saml_provider.default[key].arn
  }
  description = "Map of SAML provider names to provider ARNs"
}

output "okta_api_users" {
  value       = module.okta_api_user
  description = "Map of OKTA API Users"
}

# TODO: convert to map of policies to allow roles to be accessible from some but not all SAML providers
output "saml_provider_assume_role_policy" {
  value       = one(data.aws_iam_policy_document.saml_provider_assume[*].json)
  description = "JSON \"assume role\" policy document to use for roles allowed to log in via SAML"
}
