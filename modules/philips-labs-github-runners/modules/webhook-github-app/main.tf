resource "null_resource" "update_app" {
  triggers = {
    webhook_endpoint = var.webhook_endpoint
    webhook_secret   = var.github_app.webhook_secret
    always_run       = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/bin/update-app.sh -e ${var.webhook_endpoint} -s ${var.github_app.webhook_secret} -a ${var.github_app.id} -k ${var.github_app.key_base64}"
    on_failure  = fail
  }
}
