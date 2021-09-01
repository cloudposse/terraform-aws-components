module "example" {
  region = "us-west-2"

  client_cidr = "0.0.0.0/24"

  subnet_id = "sn-12345"

  organization_name = "Dewey, Cheatum, and Howe Penny Stocks"

  authorization_rule_target_cidr = "0.0.0.0/24"

  logging_enabled = true

  logs_retention = 0

  internet_access_enabled = false
}
