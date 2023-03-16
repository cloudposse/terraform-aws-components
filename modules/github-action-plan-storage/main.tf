
resource "aws_dynamodb_table" "default" {
  count          = var.enabled ? 1 : 0
  name           = "${module.this.id}-plans"
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  hash_key = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S"
  }

  global_secondary_index {
    name            = "id-createdAt-index"
    hash_key        = "Id"
    range_key       = "createdAt"
    write_capacity  = var.read_capacity
    read_capacity   = var.write_capacity
    projection_type = "ALL"
  }

  server_side_encryption {
    enabled = var.enable_server_side_encryption
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = module.this.tags
}

module "tfstate_backend" {
  source  = "../tfstate-backend"
  enabled = var.enabled
  context = module.this.context
  region  = var.region

  enable_server_side_encryption = var.enable_server_side_encryption
  enable_point_in_time_recovery = var.enable_point_in_time_recovery
  force_destroy                 = var.force_destroy
  prevent_unencrypted_uploads   = var.prevent_unencrypted_uploads
  access_roles                  = var.access_roles
}
