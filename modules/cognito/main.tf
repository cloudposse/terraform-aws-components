locals {
  enabled = module.this.enabled

  user_pool_name = coalesce(var.user_pool_name, module.this.id)

  # If no username_configuration is provided return a empty list
  username_configuration_default = length(var.username_configuration) == 0 ? {} : {
    case_sensitive = lookup(var.username_configuration, "case_sensitive", true)
  }

  username_configuration = length(local.username_configuration_default) == 0 ? [] : [local.username_configuration_default]

  # If no admin_create_user_config list is provided, build a admin_create_user_config using the default values
  admin_create_user_config_default = {
    allow_admin_create_user_only = lookup(var.admin_create_user_config, "allow_admin_create_user_only", null) == null ? var.admin_create_user_config_allow_admin_create_user_only : lookup(var.admin_create_user_config, "allow_admin_create_user_only")
    email_message                = lookup(var.admin_create_user_config, "email_message", null) == null ? (var.email_verification_message == "" || var.email_verification_message == null ? var.admin_create_user_config_email_message : var.email_verification_message) : lookup(var.admin_create_user_config, "email_message")
    email_subject                = lookup(var.admin_create_user_config, "email_subject", null) == null ? (var.email_verification_subject == "" || var.email_verification_subject == null ? var.admin_create_user_config_email_subject : var.email_verification_subject) : lookup(var.admin_create_user_config, "email_subject")
    sms_message                  = lookup(var.admin_create_user_config, "sms_message", null) == null ? var.admin_create_user_config_sms_message : lookup(var.admin_create_user_config, "sms_message")

  }

  admin_create_user_config = [local.admin_create_user_config_default]

  # If no sms_configuration list is provided, build a sms_configuration using the default values
  sms_configuration_default = {
    external_id    = lookup(var.sms_configuration, "external_id", null) == null ? var.sms_configuration_external_id : lookup(var.sms_configuration, "external_id")
    sns_caller_arn = lookup(var.sms_configuration, "sns_caller_arn", null) == null ? var.sms_configuration_sns_caller_arn : lookup(var.sms_configuration, "sns_caller_arn")
  }

  sms_configuration = lookup(local.sms_configuration_default, "external_id") == "" || lookup(local.sms_configuration_default, "sns_caller_arn") == "" ? [] : [local.sms_configuration_default]

  # If no device_configuration list is provided, build a device_configuration using the default values
  device_configuration_default = {
    challenge_required_on_new_device      = lookup(var.device_configuration, "challenge_required_on_new_device", null) == null ? var.device_configuration_challenge_required_on_new_device : lookup(var.device_configuration, "challenge_required_on_new_device")
    device_only_remembered_on_user_prompt = lookup(var.device_configuration, "device_only_remembered_on_user_prompt", null) == null ? var.device_configuration_device_only_remembered_on_user_prompt : lookup(var.device_configuration, "device_only_remembered_on_user_prompt")
  }

  device_configuration = lookup(local.device_configuration_default, "challenge_required_on_new_device") == false && lookup(local.device_configuration_default, "device_only_remembered_on_user_prompt") == false ? [] : [local.device_configuration_default]

  # If no email_configuration is provided, build a email_configuration using the default values
  email_configuration_default = {
    reply_to_email_address = lookup(var.email_configuration, "reply_to_email_address", null) == null ? var.email_configuration_reply_to_email_address : lookup(var.email_configuration, "reply_to_email_address")
    source_arn             = lookup(var.email_configuration, "source_arn", null) == null ? var.email_configuration_source_arn : lookup(var.email_configuration, "source_arn")
    email_sending_account  = lookup(var.email_configuration, "email_sending_account", null) == null ? var.email_configuration_email_sending_account : lookup(var.email_configuration, "email_sending_account")
    from_email_address     = lookup(var.email_configuration, "from_email_address", null) == null ? var.email_configuration_from_email_address : lookup(var.email_configuration, "from_email_address")
  }

  email_configuration = [local.email_configuration_default]

  # If no lambda_config list is provided, build a lambda_config using the default values

  # If lambda_config is null
  lambda_config_is_null = {
    create_auth_challenge          = var.lambda_config_create_auth_challenge
    custom_message                 = var.lambda_config_custom_message
    define_auth_challenge          = var.lambda_config_define_auth_challenge
    post_authentication            = var.lambda_config_post_authentication
    post_confirmation              = var.lambda_config_post_confirmation
    pre_authentication             = var.lambda_config_pre_authentication
    pre_sign_up                    = var.lambda_config_pre_sign_up
    pre_token_generation           = var.lambda_config_pre_token_generation
    user_migration                 = var.lambda_config_user_migration
    verify_auth_challenge_response = var.lambda_config_verify_auth_challenge_response
    kms_key_id                     = var.lambda_config_kms_key_id
    custom_email_sender            = var.lambda_config_custom_email_sender
    custom_sms_sender              = var.lambda_config_custom_sms_sender
  }

  # If lambda_config is NOT null
  lambda_config_not_null = var.lambda_config == null ? local.lambda_config_is_null : {
    create_auth_challenge          = lookup(var.lambda_config, "create_auth_challenge", null) == null ? var.lambda_config_create_auth_challenge : lookup(var.lambda_config, "create_auth_challenge")
    custom_message                 = lookup(var.lambda_config, "custom_message", null) == null ? var.lambda_config_custom_message : lookup(var.lambda_config, "custom_message")
    define_auth_challenge          = lookup(var.lambda_config, "define_auth_challenge", null) == null ? var.lambda_config_define_auth_challenge : lookup(var.lambda_config, "define_auth_challenge")
    post_authentication            = lookup(var.lambda_config, "post_authentication", null) == null ? var.lambda_config_post_authentication : lookup(var.lambda_config, "post_authentication")
    post_confirmation              = lookup(var.lambda_config, "post_confirmation", null) == null ? var.lambda_config_post_confirmation : lookup(var.lambda_config, "post_confirmation")
    pre_authentication             = lookup(var.lambda_config, "pre_authentication", null) == null ? var.lambda_config_pre_authentication : lookup(var.lambda_config, "pre_authentication")
    pre_sign_up                    = lookup(var.lambda_config, "pre_sign_up", null) == null ? var.lambda_config_pre_sign_up : lookup(var.lambda_config, "pre_sign_up")
    pre_token_generation           = lookup(var.lambda_config, "pre_token_generation", null) == null ? var.lambda_config_pre_token_generation : lookup(var.lambda_config, "pre_token_generation")
    user_migration                 = lookup(var.lambda_config, "user_migration", null) == null ? var.lambda_config_user_migration : lookup(var.lambda_config, "user_migration")
    verify_auth_challenge_response = lookup(var.lambda_config, "verify_auth_challenge_response", null) == null ? var.lambda_config_verify_auth_challenge_response : lookup(var.lambda_config, "verify_auth_challenge_response")
    kms_key_id                     = lookup(var.lambda_config, "kms_key_id", null) == null ? var.lambda_config_kms_key_id : lookup(var.lambda_config, "kms_key_id")
    custom_email_sender            = lookup(var.lambda_config, "custom_email_sender", null) == null ? var.lambda_config_custom_email_sender : lookup(var.lambda_config, "custom_email_sender")
    custom_sms_sender              = lookup(var.lambda_config, "custom_sms_sender", null) == null ? var.lambda_config_custom_sms_sender : lookup(var.lambda_config, "custom_sms_sender")
  }

  # Return the default values
  lambda_config = var.lambda_config == null ? [local.lambda_config_is_null] : [local.lambda_config_not_null]

  # If no password_policy is provided, build a password_policy using the default values
  # If password_policy is null
  password_policy_is_null = {
    minimum_length                   = var.password_policy_minimum_length
    require_lowercase                = var.password_policy_require_lowercase
    require_numbers                  = var.password_policy_require_numbers
    require_symbols                  = var.password_policy_require_symbols
    require_uppercase                = var.password_policy_require_uppercase
    temporary_password_validity_days = var.password_policy_temporary_password_validity_days
  }

  # If password_policy is NOT null
  password_policy_not_null = var.password_policy == null ? local.password_policy_is_null : {
    minimum_length                   = lookup(var.password_policy, "minimum_length", null) == null ? var.password_policy_minimum_length : lookup(var.password_policy, "minimum_length")
    require_lowercase                = lookup(var.password_policy, "require_lowercase", null) == null ? var.password_policy_require_lowercase : lookup(var.password_policy, "require_lowercase")
    require_numbers                  = lookup(var.password_policy, "require_numbers", null) == null ? var.password_policy_require_numbers : lookup(var.password_policy, "require_numbers")
    require_symbols                  = lookup(var.password_policy, "require_symbols", null) == null ? var.password_policy_require_symbols : lookup(var.password_policy, "require_symbols")
    require_uppercase                = lookup(var.password_policy, "require_uppercase", null) == null ? var.password_policy_require_uppercase : lookup(var.password_policy, "require_uppercase")
    temporary_password_validity_days = lookup(var.password_policy, "temporary_password_validity_days", null) == null ? var.password_policy_temporary_password_validity_days : lookup(var.password_policy, "temporary_password_validity_days")
  }

  # Return the default values
  password_policy = var.password_policy == null ? [local.password_policy_is_null] : [local.password_policy_not_null]

  # If no user_pool_add_ons is provided, build a configuration using the default values
  user_pool_add_ons_default = {
    advanced_security_mode = lookup(var.user_pool_add_ons, "advanced_security_mode", null) == null ? var.user_pool_add_ons_advanced_security_mode : lookup(var.user_pool_add_ons, "advanced_security_mode")
  }

  user_pool_add_ons = var.user_pool_add_ons_advanced_security_mode == null && length(var.user_pool_add_ons) == 0 ? [] : [local.user_pool_add_ons_default]

  # verification_message_template
  # If no verification_message_template is provided, build a verification_message_template using the default values
  verification_message_template_default = {
    default_email_option  = lookup(var.verification_message_template, "default_email_option", null) == null ? var.verification_message_template_default_email_option : lookup(var.verification_message_template, "default_email_option")
    email_message_by_link = lookup(var.verification_message_template, "email_message_by_link", null) == null ? var.verification_message_template_email_message_by_link : lookup(var.verification_message_template, "email_message_by_link")
    email_subject_by_link = lookup(var.verification_message_template, "email_subject_by_link", null) == null ? var.verification_message_template_email_subject_by_link : lookup(var.verification_message_template, "email_subject_by_link")
  }

  verification_message_template = [local.verification_message_template_default]

  # software_token_mfa_configuration
  # If no software_token_mfa_configuration is provided, build a software_token_mfa_configuration using the default values
  software_token_mfa_configuration_default = {
    enabled = lookup(var.software_token_mfa_configuration, "enabled", null) == null ? var.software_token_mfa_configuration_enabled : lookup(var.software_token_mfa_configuration, "enabled")
  }

  software_token_mfa_configuration = (length(var.sms_configuration) == 0 || local.sms_configuration == null) && var.mfa_configuration == "OFF" ? [] : [local.software_token_mfa_configuration_default]
}

resource "aws_cognito_user_pool" "pool" {
  count = local.enabled ? 1 : 0

  alias_attributes         = var.alias_attributes
  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes

  name                       = local.user_pool_name
  email_verification_subject = var.email_verification_subject == "" || var.email_verification_subject == null ? var.admin_create_user_config_email_subject : var.email_verification_subject
  email_verification_message = var.email_verification_message == "" || var.email_verification_message == null ? var.admin_create_user_config_email_message : var.email_verification_message
  mfa_configuration          = var.mfa_configuration
  sms_authentication_message = var.sms_authentication_message
  sms_verification_message   = var.sms_verification_message
  deletion_protection        = var.deletion_protection

  dynamic "username_configuration" {
    for_each = local.username_configuration
    content {
      case_sensitive = lookup(username_configuration.value, "case_sensitive")
    }
  }

  dynamic "admin_create_user_config" {
    for_each = local.admin_create_user_config
    content {
      allow_admin_create_user_only = lookup(admin_create_user_config.value, "allow_admin_create_user_only")

      dynamic "invite_message_template" {
        for_each = lookup(admin_create_user_config.value, "email_message", null) == null && lookup(admin_create_user_config.value, "email_subject", null) == null && lookup(admin_create_user_config.value, "sms_message", null) == null ? [] : [1]
        content {
          email_message = lookup(admin_create_user_config.value, "email_message")
          email_subject = lookup(admin_create_user_config.value, "email_subject")
          sms_message   = lookup(admin_create_user_config.value, "sms_message")
        }
      }
    }
  }

  dynamic "device_configuration" {
    for_each = local.device_configuration
    content {
      challenge_required_on_new_device      = lookup(device_configuration.value, "challenge_required_on_new_device")
      device_only_remembered_on_user_prompt = lookup(device_configuration.value, "device_only_remembered_on_user_prompt")
    }
  }

  dynamic "email_configuration" {
    for_each = local.email_configuration
    content {
      reply_to_email_address = lookup(email_configuration.value, "reply_to_email_address")
      source_arn             = lookup(email_configuration.value, "source_arn")
      email_sending_account  = lookup(email_configuration.value, "email_sending_account")
      from_email_address     = lookup(email_configuration.value, "from_email_address")
    }
  }

  dynamic "lambda_config" {
    for_each = var.lambda_config == null && length(local.lambda_config) == 0 ? [] : local.lambda_config
    content {
      create_auth_challenge          = lookup(lambda_config.value, "create_auth_challenge")
      custom_message                 = lookup(lambda_config.value, "custom_message")
      define_auth_challenge          = lookup(lambda_config.value, "define_auth_challenge")
      post_authentication            = lookup(lambda_config.value, "post_authentication")
      post_confirmation              = lookup(lambda_config.value, "post_confirmation")
      pre_authentication             = lookup(lambda_config.value, "pre_authentication")
      pre_sign_up                    = lookup(lambda_config.value, "pre_sign_up")
      pre_token_generation           = lookup(lambda_config.value, "pre_token_generation")
      user_migration                 = lookup(lambda_config.value, "user_migration")
      verify_auth_challenge_response = lookup(lambda_config.value, "verify_auth_challenge_response")
      kms_key_id                     = lookup(lambda_config.value, "kms_key_id")
      dynamic "custom_email_sender" {
        for_each = length(lambda_config.value["custom_email_sender"]) == 0 ? [] : [1]
        content {
          lambda_arn     = lambda_config.value["custom_email_sender"]["lambda_arn"]
          lambda_version = lambda_config.value["custom_email_sender"]["lambda_version"]
        }
      }
      dynamic "custom_sms_sender" {
        for_each = length(lambda_config.value["custom_sms_sender"]) == 0 ? [] : [1]
        content {
          lambda_arn     = lambda_config.value["custom_sms_sender"]["lambda_arn"]
          lambda_version = lambda_config.value["custom_sms_sender"]["lambda_version"]
        }
      }
    }
  }

  dynamic "sms_configuration" {
    for_each = local.sms_configuration
    content {
      external_id    = lookup(sms_configuration.value, "external_id")
      sns_caller_arn = lookup(sms_configuration.value, "sns_caller_arn")
    }
  }

  dynamic "software_token_mfa_configuration" {
    for_each = local.software_token_mfa_configuration
    content {
      enabled = lookup(software_token_mfa_configuration.value, "enabled")
    }
  }

  dynamic "password_policy" {
    for_each = local.password_policy
    content {
      minimum_length                   = lookup(password_policy.value, "minimum_length")
      require_lowercase                = lookup(password_policy.value, "require_lowercase")
      require_numbers                  = lookup(password_policy.value, "require_numbers")
      require_symbols                  = lookup(password_policy.value, "require_symbols")
      require_uppercase                = lookup(password_policy.value, "require_uppercase")
      temporary_password_validity_days = lookup(password_policy.value, "temporary_password_validity_days")
    }
  }

  dynamic "schema" {
    for_each = var.schemas == null ? [] : var.schemas
    content {
      attribute_data_type      = lookup(schema.value, "attribute_data_type")
      developer_only_attribute = lookup(schema.value, "developer_only_attribute")
      mutable                  = lookup(schema.value, "mutable")
      name                     = lookup(schema.value, "name")
      required                 = lookup(schema.value, "required")
    }
  }

  dynamic "schema" {
    for_each = var.string_schemas == null ? [] : var.string_schemas
    content {
      attribute_data_type      = lookup(schema.value, "attribute_data_type")
      developer_only_attribute = lookup(schema.value, "developer_only_attribute")
      mutable                  = lookup(schema.value, "mutable")
      name                     = lookup(schema.value, "name")
      required                 = lookup(schema.value, "required")

      # string_attribute_constraints
      dynamic "string_attribute_constraints" {
        for_each = length(lookup(schema.value, "string_attribute_constraints")) == 0 ? [] : [lookup(schema.value, "string_attribute_constraints", {})]
        content {
          min_length = lookup(string_attribute_constraints.value, "min_length", 0)
          max_length = lookup(string_attribute_constraints.value, "max_length", 0)
        }
      }
    }
  }

  dynamic "schema" {
    for_each = var.number_schemas == null ? [] : var.number_schemas
    content {
      attribute_data_type      = lookup(schema.value, "attribute_data_type")
      developer_only_attribute = lookup(schema.value, "developer_only_attribute")
      mutable                  = lookup(schema.value, "mutable")
      name                     = lookup(schema.value, "name")
      required                 = lookup(schema.value, "required")

      # number_attribute_constraints
      dynamic "number_attribute_constraints" {
        for_each = length(lookup(schema.value, "number_attribute_constraints")) == 0 ? [] : [lookup(schema.value, "number_attribute_constraints", {})]
        content {
          min_value = lookup(number_attribute_constraints.value, "min_value", 0)
          max_value = lookup(number_attribute_constraints.value, "max_value", 0)
        }
      }
    }
  }

  dynamic "user_pool_add_ons" {
    for_each = local.user_pool_add_ons
    content {
      advanced_security_mode = lookup(user_pool_add_ons.value, "advanced_security_mode")
    }
  }

  dynamic "verification_message_template" {
    for_each = local.verification_message_template
    content {
      default_email_option  = lookup(verification_message_template.value, "default_email_option")
      email_message_by_link = lookup(verification_message_template.value, "email_message_by_link")
      email_subject_by_link = lookup(verification_message_template.value, "email_subject_by_link")
    }
  }

  dynamic "account_recovery_setting" {
    for_each = length(var.recovery_mechanisms) == 0 ? [] : [1]
    content {
      # recovery_mechanism
      dynamic "recovery_mechanism" {
        for_each = var.recovery_mechanisms
        content {
          name     = lookup(recovery_mechanism.value, "name")
          priority = lookup(recovery_mechanism.value, "priority")
        }
      }
    }
  }

  tags = module.this.tags
}
