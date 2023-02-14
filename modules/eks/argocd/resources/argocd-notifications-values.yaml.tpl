notifications:
  secret:
    # create: false # Do not create an argocd-notifications-secret — this secret should instead be created via sops-secrets-operator
    create: true

  argocdUrl: ${argocd_host}

  notifiers:
  %{ if slack_notifications_enabled == true }
    service.slack: |
      token: $slack-token
      username: "${slack_notifications_username}"
      icon: "${slack_notifications_icon}"
  %{ endif }
  %{ if github_notifications_enabled == true }
  # The webhook service notification configuration for GitHub cannot be consolidated into a single service because at least
  # one of the notification templates requires the use of more than one GitHub endpoint via the webhook service. Since the
  # webhook service configuration is a map, with each endpoint having its own key, we must also configure each key below,
  # even if the configuration itself is exactly the same.
  # See: https://github.com/argoproj/notifications-engine/blob/32519f8f68ec85d8ac3741d4ad52f7f5476ce5e7/pkg/services/webhook.go#L23
    service.webhook.github-commit-status: |
      url: "https://api.github.com"
      headers:
      - name: "Authorization"
        value: "token $github-token"
    service.webhook.github-deployment: |
      url: "https://api.github.com"
      headers:
      - name: "Authorization"
        value: "token $github-token"
  %{ endif }
  %{ if datadog_notifications_enabled == true }
    service.webhook.datadog: |
      url: "https://api.datadoghq.com/api/v1/events"
      headers:
      - name: "DD-API-KEY"
        value: "$datadog-api-key"
      - name: "Content-Type"
        value: "application/json"
  %{ endif }
