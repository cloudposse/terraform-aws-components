module "example" {
  source = "../.."

  example = var.example

  context = module.this.context
}
