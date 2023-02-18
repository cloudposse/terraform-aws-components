replicaCount: 1

podAnnotations: { }

serviceAccount:
  create: true
  name: "datadog-synthetics-private-location"

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi

configFile: |-
  {
    "id": "${id}",
    "datadogApiKey": "${datadogApiKey}",
    "accessKey": "${accessKey}",
    "secretAccessKey": "${secretAccessKey}",
    "site": "${site}"
  }

env:
  - name: DATADOG_PRIVATE_KEY
    value: |-
      ${privateKey}
  - name: DATADOG_PUBLIC_KEY_PEM
    value: |-
      ${publicKey_pem}
  - name: DATADOG_PUBLIC_KEY_FINGERPRINT
    value: ${publicKey_fingerprint}
