# This file is included by default in terraform plans

enabled = true

name = "eks"

standard_service_accounts = [
  "autoscaler",
  "cert-manager",
  "external-dns"
]

optional_service_accounts = []
