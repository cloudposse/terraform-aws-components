locals {
  enabled  = module.this.enabled
  zone_map = zipmap(var.zone_config[*].subdomain, var.zone_config[*].zone_name)

  private_enabled = local.enabled && var.dns_private_zone_enabled
  public_enabled  = local.enabled && !local.private_enabled

  private_ca_enabled = local.private_enabled && var.certificate_authority_enabled

  aws_route53_zone = local.private_enabled ? aws_route53_zone.private : aws_route53_zone.default

  vpc_environment_names = toset(concat([var.vpc_primary_environment_name], var.vpc_secondary_environment_names))

  aws_partition = join("", data.aws_partition.current.*.partition)
}

resource "aws_route53_zone" "default" {
  for_each = local.public_enabled ? local.zone_map : {}

  name    = format("%s.%s", each.key, each.value)
  comment = format("DNS zone for %s.%s", each.key, each.value)


  tags = module.this.tags
}

resource "aws_route53_zone" "private" {
  for_each = local.private_enabled ? local.zone_map : {}

  name    = format("%s.%s", each.key, each.value)
  comment = format("DNS zone for %s.%s", each.key, each.value)

  # The reason why this isn't in the original route53 zone is because this shows up as an update
  # when the aws provider should replace it. Using a separate resource allows the user to toggle
  # between private and public without manual targeted destroys.
  # See: https://github.com/hashicorp/terraform-provider-aws/issues/7614
  dynamic "vpc" {
    for_each = local.private_enabled ? [true] : []

    content {
      vpc_id = module.vpc[var.vpc_primary_environment_name].outputs.vpc_id
    }
  }

  tags = module.this.tags

  # Prevent the deletion of associated VPCs after
  # the initial creation. See documentation on
  # aws_route53_zone_association for details
  # See https://github.com/hashicorp/terraform-provider-aws/issues/14872#issuecomment-682008493
  lifecycle {
    ignore_changes = [vpc]
  }
}

module "utils" {
  source  = "cloudposse/utils/aws"
  version = "1.3.0"
}

resource "aws_route53_zone_association" "secondary" {
  for_each = local.private_enabled && length(var.vpc_secondary_environment_names) > 0 ? toset(var.vpc_secondary_environment_names) : toset([])

  zone_id    = join("", local.aws_route53_zone.*.zone_id)
  vpc_id     = module.vpc[each.value].outputs.vpc_id
  vpc_region = module.utils.region_az_alt_code_maps[format("from_%s", var.vpc_region_abbreviation_type)][each.value]
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

resource "aws_shield_protection" "shield_protection" {
  for_each = local.enabled && var.aws_shield_protection_enabled ? local.aws_route53_zone : {}

  name         = local.aws_route53_zone[each.key].name
  resource_arn = format("arn:%s:route53:::hostedzone/%s", local.aws_partition, local.aws_route53_zone[each.key].id)

  tags = module.this.tags
}

resource "aws_route53_record" "soa" {
  for_each = local.enabled ? local.aws_route53_zone : {}

  allow_overwrite = true
  name            = local.aws_route53_zone[each.key].name
  type            = "SOA"
  ttl             = "60"
  zone_id         = local.aws_route53_zone[each.key].zone_id

  records = [
    format("${local.aws_route53_zone[each.key].name_servers[0]}%s %s", local.public_enabled ? "." : "", var.dns_soa_config)
  ]
}

data "aws_route53_zone" "root_zone" {
  for_each = local.enabled ? local.zone_map : {}
  provider = aws.primary

  name         = format("%s.", each.value)
  private_zone = false
}

resource "aws_route53_record" "root_ns" {
  for_each = local.enabled ? data.aws_route53_zone.root_zone : {}
  provider = aws.primary

  allow_overwrite = true
  name            = each.key
  records         = local.aws_route53_zone[each.key].name_servers
  type            = "NS"
  ttl             = "30"
  zone_id         = data.aws_route53_zone.root_zone[each.key].zone_id
}
