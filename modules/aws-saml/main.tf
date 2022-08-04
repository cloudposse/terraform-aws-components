locals {
  saml_providers = module.this.enabled ? var.saml_providers : {}
  okta_providers = toset([for k, v in local.saml_providers : k if length(regexall("(?i:okta)", v)) > 0])
}

resource "aws_iam_saml_provider" "default" {
  for_each               = local.saml_providers
  name                   = format("%s-%s", module.this.id, each.key)
  saml_metadata_document = file(each.value)
}

module "okta_api_user" {
  for_each = local.okta_providers
  source   = "./modules/okta-user"

  attributes = [each.key, "oktaapi"]

  context = module.this.context
}

data "aws_iam_policy_document" "saml_provider_assume" {
  count = length(local.saml_providers) > 0 ? 1 : 0

  statement {
    sid = "SamlProviderAssume"
    actions = [
      "sts:AssumeRoleWithSAML",
      "sts:TagSession",
    ]

    principals {
      type = "Federated"

      identifiers = [for name, provider in aws_iam_saml_provider.default : provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }
}

