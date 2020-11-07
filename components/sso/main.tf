resource "aws_iam_saml_provider" "default" {
  for_each               = var.saml_providers
  name                   = format("%s-%s", module.this.id, each.key)
  saml_metadata_document = file(each.value)
}
