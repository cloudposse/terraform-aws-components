locals {
  enabled                                = module.this.enabled
  account_map                            = module.account_map.outputs.full_account_map
  org_delegated_administrator_account_id = local.account_map[var.delegated_administrator_account_name]
}

resource "aws_accessanalyzer_analyzer" "organization" {
  count = local.enabled && var.accessanalyzer_organization_enabled ? 1 : 0

  analyzer_name = format("%s-organization", module.this.id)
  type          = "ORGANIZATION"

  tags = module.this.tags
}

resource "aws_accessanalyzer_analyzer" "organization_unused_access" {
  count = local.enabled && var.accessanalyzer_organization_unused_access_enabled ? 1 : 0

  analyzer_name = format("%s-organization-unused-access", module.this.id)
  type          = "ORGANIZATION_UNUSED_ACCESS"

  configuration {
    unused_access {
      unused_access_age = var.unused_access_age
    }
  }

  tags = module.this.tags
}

# Delegate Access Analyzer to the administrator account (usually the security account)
resource "aws_organizations_delegated_administrator" "default" {
  count = local.enabled && var.organizations_delegated_administrator_enabled ? 1 : 0

  account_id        = local.org_delegated_administrator_account_id
  service_principal = var.accessanalyzer_service_principal
}
