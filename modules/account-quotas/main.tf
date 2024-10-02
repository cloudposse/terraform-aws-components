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

  # Because the API often returns default values rather than configured or applicable values,
  # we have to ignore the value returned by the API or else face perpetual drift.
  # To allow us to change the value in the future, even though we are ignoring it,
  # we encode the value in the resource key, so that a change of value will
  # result in a new resource being created and the old one being destroyed.
  # Destroying the old resource has no actual effect, it does not even close
  # an open request, so it is safe to do.

  quota_requests = { for k, quota in local.quotas_coded_map :
    format("%v/%v/%v", quota.service_code, quota.quota_code, quota.value) => merge(
      quota, { input_map_key = k }
    )
  }

  quota_results = { for k, v in local.quota_requests : v.input_map_key => merge(
    { for k, v in aws_servicequotas_service_quota.this[k] : k => v if k != "value" },
    { "value reported (may be inaccurate)" = aws_servicequotas_service_quota.this[k].value },
    { "value requested" = v.value }
  ) }
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
  for_each = local.quota_requests

  quota_code   = each.value.quota_code
  service_code = each.value.service_code
  value        = each.value.value

  lifecycle {
    # Literally about 50% of the time, the actual value set is not available,
    # so the default value is reported instead, resulting in permanent drift.
    ignore_changes = [value]
  }
}
