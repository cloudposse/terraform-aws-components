# This file is included by default in terraform plans

enabled = false

name = "external-dns"

chart            = "external-dns"
chart_repository = "https://charts.bitnami.com/bitnami"
chart_version    = "5.4.8"

create_namespace     = true
kubernetes_namespace = "external-dns"
