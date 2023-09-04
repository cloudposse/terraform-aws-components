notifications:
  secret:
    # create: false # Do not create an argocd-notifications-secret — this secret should instead be created via sops-secrets-operator
    create: true

  argocdUrl: ${argocd_host}
  podAnnotations:
    checksum/config: ${configs-hash}
    checksum/secrets:  ${secrets-hash}
