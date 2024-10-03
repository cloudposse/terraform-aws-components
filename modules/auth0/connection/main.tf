locals {
  enabled = module.this.enabled

  # If var.template is set, use it.
  # Otherwise, if var.template_file is set, use that file content.
  # Otherwise, use null.
  template = length(var.template) > 0 ? var.template : length(var.template_file) > 0 ? file("${path.module}/${var.template_file}") : null
}

resource "auth0_connection" "this" {
  count = local.enabled ? 1 : 0

  strategy = var.strategy
  name     = length(var.connection_name) > 0 ? var.connection_name : module.this.name

  options {
    name     = var.options_name
    from     = var.email_from
    subject  = var.email_subject
    syntax   = var.syntax
    template = local.template

    disable_signup           = var.disable_signup
    brute_force_protection   = var.brute_force_protection
    set_user_root_attributes = var.set_user_root_attributes
    non_persistent_attrs     = var.non_persistent_attrs
    auth_params              = var.auth_params

    totp {
      time_step = var.totp.time_step
      length    = var.totp.length
    }
  }
}

resource "auth0_connection_clients" "this" {
  count = local.enabled ? 1 : 0

  connection_id   = auth0_connection.this[0].id
  enabled_clients = length(module.auth0_apps) > 0 ? [for auth0_app in module.auth0_apps : auth0_app.outputs.auth0_client_id] : []
}
