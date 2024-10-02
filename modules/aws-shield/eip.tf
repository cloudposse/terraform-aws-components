data "aws_eip" "eip" {
  for_each = local.eip_protection_enabled ? toset(var.eips) : []

  public_ip = each.key
}

resource "aws_shield_protection" "eip_shield_protection" {
  for_each = local.eip_protection_enabled ? data.aws_eip.eip : {}

  name         = data.aws_eip.eip[each.key].id
  resource_arn = "arn:${local.partition}:ec2:${var.region}:${local.account_id}:eip-allocation/${data.aws_eip.eip[each.key].id}"

  tags = local.tags
}
