output "service_accounts" {
  # Use ServiceAccount names as keys. This should make it easier to use "module for_each".
  value = { for sa in local.service_account_list : sa => local.output_map[sa] }
}
