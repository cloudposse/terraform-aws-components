locals {
  enabled = module.this.enabled
}

data "aws_ssoadmin_instances" "root" {}

resource "aws_ssoadmin_application" "sso_app" {
  count = local.enabled ? 1 : 0

  name        = module.this.id
  description = var.description

  application_account      = null
  application_provider_arn = var.application_provider_arn
  instance_arn             = tolist(data.aws_ssoadmin_instances.root.arns)[0]


  dynamic "portal_options" {
    for_each = var.portal_options
    content {
      dynamic "sign_in_options" {
        for_each = portal_options.value.sign_in_options
        content {
          application_url = sign_in_options.value.application_url
          origin          = sign_in_options.value.origin
        }
      }
      visibility = portal_options.value.visibility
    }
  }

}
