locals {
  quotas           = module.this.enabled ? { for k, v in var.quotas : k => v if v != null } : {}
  service_name_set = toset(compact(values(local.quotas).*.service_name))

  quotas_with_service_codes = { for k, quota in local.quotas : k => {
    service_code = quota.service_code != null ? quota.service_code : data.aws_servicequotas_service.by_name[quota.service_name].service_code
    quota_name   = quota.quota_name
    quota_code   = quota.quota_code
    value        = quota.value
    }
  }

  quota_name_map = { for k, quota in local.quotas_with_service_codes : k => {
    service_code = quota.service_code
    quota_name   = quota.quota_name
    } if quota.quota_code == null
  }

  quotas_coded_map = { for k, quota in local.quotas_with_service_codes : k => {
    service_code = quota.service_code
    quota_code   = quota.quota_code != null ? quota.quota_code : data.aws_servicequotas_service_quota.by_name[k].quota_code
    value        = quota.value
  } }
}

data "aws_servicequotas_service" "by_name" {
  for_each = local.service_name_set

  service_name = each.value
}

data "aws_servicequotas_service_quota" "by_name" {
  for_each = local.quota_name_map

  quota_name   = each.value.quota_name
  service_code = each.value.service_code
}

resource "aws_servicequotas_service_quota" "this" {
  for_each = local.quotas_coded_map

  quota_code   = each.value.quota_code
  service_code = each.value.service_code
  value        = each.value.value
}
