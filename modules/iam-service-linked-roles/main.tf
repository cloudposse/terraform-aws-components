locals {
  enabled              = module.this.enabled
  service_linked_roles = local.enabled ? var.service_linked_roles : {}
}

resource "aws_iam_service_linked_role" "default" {
  for_each = local.service_linked_roles

  aws_service_name = each.value.aws_service_name
  description      = each.value.description

  tags = module.this.tags
}
