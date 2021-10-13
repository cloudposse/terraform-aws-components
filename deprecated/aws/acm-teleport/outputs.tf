output "certificate_domain_name" {
  value = "${var.domain_name}"
}

output "certificate_id" {
  value = "${module.certificate.id}"
}

output "certificate_arn" {
  value = "${module.certificate.arn}"
}

output "certificate_domain_validation_options" {
  value = "${module.certificate.domain_validation_options}"
}
