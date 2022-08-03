# This file is included by default in terraform plans

enabled = false

name = "reloader"

create_namespace     = true
kubernetes_namespace = "reloader"

repository = "https://stakater.github.io/stakater-charts"
chart      = "reloader"

chart_version = "v0.0.68"

timeout = 180

wait = true
