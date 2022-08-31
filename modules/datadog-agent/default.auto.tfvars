enabled = false

name = "datadog"

description = "Datadog Kubernetes Agent"

kubernetes_namespace = "monitoring"

create_namespace = true

repository = "https://helm.datadoghq.com"

chart = "datadog"

chart_version = "2.32.6"

timeout = 180

wait = true

atomic = true

cleanup_on_fail = true
