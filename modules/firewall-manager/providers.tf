provider "aws" {
  region = "us-east-1"
//  assume_role {
//    role_arn = var.assume_arn
//  }
  dynamic "assume_role" {
    for_each = var.assume_arn
    content {
      role_arn = assume_role.value
    }
  }
}
