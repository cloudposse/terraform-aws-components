locals {
  opsgenie_api_key = data.aws_ssm_parameter.opsgenie_api_key.value

  opsgenie_resources = merge(
    [
      for resource_file in fileset("${path.module}/resources", "*.yaml") : {
        for k, v in yamldecode(file(format("%s/%s", "${path.module}/resources", resource_file))) : k => v
      }
  ]...)

  services = flatten(
    [
      for resource_file in fileset("${path.module}/resources/services", "*.yaml") : [
        for k, v in lookup(yamldecode(file(format("%s/%s", "${path.module}/resources/services", resource_file))), "service") : v
      ]
    ]
  )

  alert_policies = flatten(
    [
      for resource_file in fileset("${path.module}/resources/services", "*.yaml") : [
        for k, v in lookup(yamldecode(file(format("%s/%s", "${path.module}/resources/services", resource_file))), "alert_policies", []) : v
      ]
    ]
  )

  service_incident_rules = flatten(
    [
      for resource_file in fileset("${path.module}/resources/services", "*.yaml") : [
        for k, v in lookup(yamldecode(file(format("%s/%s", "${path.module}/resources/services", resource_file))), "service_incident_rules", []) : v
      ]
    ]
  )
}

module "opsgenie_config" {
  source = "git::https://github.com/cloudposse/terraform-opsgenie-incident-management.git//modules/config?ref=0.9.0"

  opsgenie_resources = merge(
    local.opsgenie_resources,
    { services : local.services },
    { alert_policies : local.alert_policies },
    { service_incident_rules : local.service_incident_rules }
  )
}
