# security-group-variables Version: 3
#
# Copy this file from https://github.com/cloudposse/terraform-aws-security-group/blob/master/exports/security-group-variables.tf
# and EDIT IT TO SUIT YOUR PROJECT. Update the version number above if you update this file from a later version.
# Unlike null-label context.tf, this file cannot be automatically updated
# because of the tight integration with the module using it.
##
# Delete this top comment block, except for the first line (version number),
# REMOVE COMMENTS below that are intended for the initial implementer and not maintainers or end users.
#
# This file provides the standard inputs that all Cloud Posse Open Source
# Terraform module that create AWS Security Groups should implement.
# This file does NOT provide implementation of the inputs, as that
# of course varies with each module.
#
# This file declares some standard outputs modules should create,
# but the declarations should be moved to `outputs.tf` and of course
# may need to be modified based on the module's use of security-group.
#


variable "create_security_group" {
  type        = bool
  description = "Set `true` to create and configure a new security group. If false, `associated_security_group_ids` must be provided."
  default     = true
}

variable "associated_security_group_ids" {
  type        = list(string)
  description = <<-EOT
    A list of IDs of Security Groups to associate the created resource with, in addition to the created security group.
    These security groups will not be modified and, if `create_security_group` is `false`, must have rules providing the desired access.
    EOT
  default     = []
}

##
## allowed_* inputs are optional, because the same thing can be accomplished by
## providing `additional_security_group_rules`. However, if the rules this
## module creates are non-trivial (for example, opening ports based on
## feature settings, see https://github.com/cloudposse/terraform-aws-msk-apache-kafka-cluster/blob/3fe23c402cc420799ae721186812482335f78d24/main.tf#L14-L53 )
## then it makes sense to include these.
## Reasons not to include some or all of these inputs include
## - too hard to implement
## - does not make sense (particularly the IPv6 inputs if the underlying resource does not yet support IPv6)
## - likely to confuse users
## - likely to invite count/for_each issues
variable "allowed_security_group_ids" {
  type        = list(string)
  description = <<-EOT
    A list of IDs of Security Groups to allow access to the security group created by this module.
    The length of this list must be known at "plan" time.
    EOT
  default     = []
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = <<-EOT
    A list of IPv4 CIDRs to allow access to the security group created by this module.
    The length of this list must be known at "plan" time.
    EOT
  default     = []
}
## End of optional allowed_* ###########

variable "security_group_name" {
  type        = list(string)
  description = <<-EOT
    The name to assign to the created security group. Must be unique within the VPC.
    If not provided, will be derived from the `null-label.context` passed in.
    If `create_before_destroy` is true, will be used as a name prefix.
    EOT
  default     = []
}

variable "security_group_description" {
  type        = string
  description = <<-EOT
    The description to assign to the created Security Group.
    Warning: Changing the description causes the security group to be replaced.
    EOT
  default     = "Managed by Terraform"
}

variable "security_group_create_before_destroy" {
  type        = bool
  description = <<-EOT
    Set `true` to enable terraform `create_before_destroy` behavior on the created security group.
    We only recommend setting this `false` if you are importing an existing security group
    that you do not want replaced and therefore need full control over its name.
    Note that changing this value will always cause the security group to be replaced.
    EOT
  default     = true
}

variable "preserve_security_group_id" {
  type        = bool
  description = <<-EOT
    When `false` and `security_group_create_before_destroy` is `true`, changes to security group rules
    cause a new security group to be created with the new rules, and the existing security group is then
    replaced with the new one, eliminating any service interruption.
    When `true` or when changing the value (from `false` to `true` or from `true` to `false`),
    existing security group rules will be deleted before new ones are created, resulting in a service interruption,
    but preserving the security group itself.
    **NOTE:** Setting this to `true` does not guarantee the security group will never be replaced,
    it only keeps changes to the security group rules from triggering a replacement.
    See the [terraform-aws-security-group README](https://github.com/cloudposse/terraform-aws-security-group) for further discussion.
    EOT
  default     = false
}

variable "security_group_create_timeout" {
  type        = string
  description = "How long to wait for the security group to be created."
  default     = "10m"
}

variable "security_group_delete_timeout" {
  type        = string
  description = <<-EOT
    How long to retry on `DependencyViolation` errors during security group deletion from
    lingering ENIs left by certain AWS services such as Elastic Load Balancing.
    EOT
  default     = "15m"
}

variable "allow_all_egress" {
  type        = bool
  description = <<-EOT
    If `true`, the created security group will allow egress on all ports and protocols to all IP addresses.
    If this is false and no egress rules are otherwise specified, then no egress will be allowed.
    EOT
  default     = true
}

variable "additional_security_group_rules" {
  type        = list(any)
  description = <<-EOT
    A list of Security Group rule objects to add to the created security group, in addition to the ones
    this module normally creates. (To suppress the module's rules, set `create_security_group` to false
    and supply your own security group(s) via `associated_security_group_ids`.)
    The keys and values of the objects are fully compatible with the `aws_security_group_rule` resource, except
    for `security_group_id` which will be ignored, and the optional "key" which, if provided, must be unique and known at "plan" time.
    For more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
    and https://github.com/cloudposse/terraform-aws-security-group.
    EOT
  default     = []
}

#### We do not expose an `additional_security_group_rule_matrix` input for a few reasons:
# - It is a convenience and ultimately provides no rules that cannot be provided via `additional_security_group_rules`
# - It is complicated and can, in some situations, create problems for Terraform `for_each`
# - It is difficult to document and easy to make mistakes using it


#
#
#### The variables below (but not the outputs) can be omitted if not needed, and may need their descriptions modified
#
#

#############################################################################################
## Special note about inline_rules_enabled and revoke_rules_on_delete
##
## The security-group inputs inline_rules_enabled and revoke_rules_on_delete should not
## be exposed in other modules unless there is a strong reason for them to be used.
## We discourage the use of inline_rules_enabled and we rarely need or want
## revoke_rules_on_delete, so we do not want to clutter our interface with those inputs.
##
## If someone wants to enable either of those options, they have the option
## of creating a security group configured as they like
## and passing it in as the target security group.
#############################################################################################

variable "inline_rules_enabled" {
  type        = bool
  description = <<-EOT
    NOT RECOMMENDED. Create rules "inline" instead of as separate `aws_security_group_rule` resources.
    See [#20046](https://github.com/hashicorp/terraform-provider-aws/issues/20046) for one of several issues with inline rules.
    See [this post](https://github.com/hashicorp/terraform-provider-aws/pull/9032#issuecomment-639545250) for details on the difference between inline rules and rule resources.
    EOT
  default     = false
}
