resource "null_resource" "is_apply" {
  provisioner "local-exec" {
    command = "echo 'is_destroy = false' > ${path.module}/command.auto.tfvars"
  }
}
resource "null_resource" "is_destroy" {
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'is_destroy = true' > ${path.module}/command.auto.tfvars"
  }
}

locals {
  region = "us-east-1" // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fms_admin_account
}

module "aws_firewall_manager" {
  //  source = "git::https://github.com/cloudposse/terraform-aws-firewall-manager.git?ref=ALTAIS-372"
  source = "../../../terraform-aws-firewall-manager/"
  context = module.this.context

  region            = local.region
  admin_account_ids = var.admin_account_ids
  is_destroy        = var.is_destroy

  security_groups_common_policies           = var.security_groups_common_policies
  security_groups_content_audit_policies    = var.security_groups_content_audit_policies
  security_groups_usage_audit_policies      = var.security_groups_usage_audit_policies
  shiled_advanced_policies                  = var.shiled_advanced_policies
  waf_policies                              = var.waf_policies
  waf_v2_policies                           = var.waf_v2_policies
  dns_firewall_policies                     = var.dns_firewall_policies
  network_firewall_policies                 = var.network_firewall_policies

}
