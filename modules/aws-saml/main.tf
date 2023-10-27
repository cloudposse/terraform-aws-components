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
      "sts:SetSourceIdentity",
      "sts:TagSession",
    ]

    principals {
      type = "Federated"

      identifiers = [for name, provider in aws_iam_saml_provider.default : provider.arn]
    }

    condition {
      # Use StringLike rather than StringEquals to avoid having to list every region's endpoint
      test     = "StringLike"
      variable = "SAML:aud"
      # Allow sign in from any valid AWS SAML endpoint
      # See https://docs.aws.amazon.com/general/latest/gr/signin-service.html
      # and https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html#condition-keys-saml
      # Note: The value for this key comes from the SAML Recipient field in the assertion, not the Audience field,
      # and is thus not the actual SAML:aud in the SAML assertion.
      values = [
        "https://signin.aws.amazon.com/saml",
        "https://*.signin.aws.amazon.com/saml",
        "https://signin.amazonaws-us-gov.com/saml",
        "https://us-gov-east-1.signin.amazonaws-us-gov.com/saml",
      ]
    }
  }
}
