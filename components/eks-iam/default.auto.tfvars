# This file is included by default in terraform plans

name = "eks"

standard_service_accounts = [
  "autoscaler",
  "cert-manager",
  "external-dns"
]

optional_service_accounts = []
