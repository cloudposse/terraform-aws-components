enabled = false

name = "datadog"

description = "Datadog Kubernetes Agent"

kubernetes_namespace = "monitoring"

create_namespace = true

repository = "https://helm.datadoghq.com"

chart = "datadog"

# https://github.com/DataDog/helm-charts/releases
# 2.26.2 released on Nov 19, 2021
chart_version = "2.26.2"

timeout = 180

wait = true

atomic = true

cleanup_on_fail = true
