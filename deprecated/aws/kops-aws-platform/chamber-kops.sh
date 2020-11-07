#!/usr/bin/env bash

echo "*WARNING* This script is probably out of date. Chamber is the only system of record for secrets"
echo "This file is just an example"
echo "*WARNING* Running this file as it is (without specifying the correct values) will destroy some secrets and break the environment"
echo "To add/update secrets, first edit this file and set values (replace XXXXXXXXXXXX with the correct values)"
echo "Then comment out 'exit 1' and run the file"
echo "Then undo the editing and uncomment 'exit 1'"
echo "Never commit this file with sensitive data. Run 'git reset --hard' if done accidentally"

exit 1


## Chart Museum
chamber write kops CHARTMUSEUM_BASIC_AUTH_USER XXXXXXXXXXXX   # e.g. server
chamber write kops CHARTMUSEUM_BASIC_AUTH_PASS XXXXXXXXXXXX
chamber write kops CHARTMUSEUM_HOSTNAME XXXXXXXXXXXX   # e.g. charts.us-west-2.staging.cloudposse.co
chamber write kops CHARTMUSEUM_INGRESS XXXXXXXXXXXX   # e.g. ingress.us-west-2.staging.cloudposse.co


## Chart Repo
chamber write kops CHART_REPO_STORAGE_AMAZON_BUCKET XXXXXXXXXXXX   # e.g. cp-staging-chart-repo
chamber write kops CHART_REPO_STORAGE_AMAZON_REGION XXXXXXXXXXXX   # e.g. us-west-2
chamber write kops CHART_REPO_STORAGE_AWS_IAM_ROLE XXXXXXXXXXXX   # e.g. cp-staging-chart-repo
chamber write kops CHART_REPO_GATEWAY_HOSTNAME XXXXXXXXXXXX   # e.g. gateway.charts.us-west-2.staging.cloudposse.co
chamber write kops CHART_REPO_GATEWAY_INGRESS XXXXXXXXXXXX   # e.g. ingress.us-west-2.staging.cloudposse.co
chamber write kops CHART_REPO_GATEWAY_BASIC_AUTH_USER XXXXXXXXXXXX   # e.g. gateway
chamber write kops CHART_REPO_GATEWAY_BASIC_AUTH_PASS XXXXXXXXXXXX
chamber write kops CHART_REPO_SERVER_HOSTNAME XXXXXXXXXXXX   # e.g. charts.us-west-2.staging.cloudposse.co
chamber write kops CHART_REPO_SERVER_INGRESS XXXXXXXXXXXX   # e.g. ingress.us-west-2.staging.cloudposse.co
chamber write kops CHART_REPO_SERVER_BASIC_AUTH_USER XXXXXXXXXXXX   # e.g. server
chamber write kops CHART_REPO_SERVER_BASIC_AUTH_PASS XXXXXXXXXXXX


## External DNS
chamber write kops EXTERNAL_DNS_TXT_OWNER_ID XXXXXXXXXXXX   # e.g. us-west-2.staging.cloudposse.co
chamber write kops EXTERNAL_DNS_TXT_PREFIX XXXXXXXXXXXX   # e.g. 184f3df5-53c6-4071-974b-2d8de32e82c7-
chamber write kops EXTERNAL_DNS_IAM_ROLE XXXXXXXXXXXX   # e.g. cp-staging-external-dns


## Kube Lego - Automatic Let's Encrypt for Ingress
chamber write kops KUBE_LEGO_EMAIL XXXXXXXXXXXX   # e.g. awsadmin@cloudposse.co


## NGINX Ingress Controller
chamber write kops NGINX_INGRESS_HOSTNAME XXXXXXXXXXXX   # e.g. ingress.us-west-2.staging.cloudposse.co


## prometheus-operator
## creates/configures/manages Prometheus clusters atop Kubernetes
chamber write kops PROMETHEUS_OPERATOR_IMAGE_TAG XXXXXXXXXXXX   # e.g. v0.17.0
chamber write kops PROMETHEUS_OPERATOR_GLOBAL_HYPERKUBE_IMAGE_TAG XXXXXXXXXXXX   # e.g. v1.7.6_coreos.0
chamber write kops PROMETHEUS_OPERATOR_PROMETHEUS_CONFIG_RELOADER_IMAGE_TAG XXXXXXXXXXXX   # e.g. v0.0.3
chamber write kops PROMETHEUS_OPERATOR_CONFIGMAP_RELOAD_IMAGE_TAG XXXXXXXXXXXX   # e.g. v0.0.1


## kube-prometheus
## Collects Kubernetes manifests, Grafana dashboards, and Prometheus rules
## combined with documentation and scripts to provide single-command
## deployments of end-to-end Kubernetes cluster monitoring with Prometheus operator
chamber write kops KUBE_PROMETHEUS_ALERT_MANAGER_REPLICA_COUNT XXXXXXXXXXXX   # e.g. 4
chamber write kops KUBE_PROMETHEUS_ALERT_MANAGER_IMAGE_TAG XXXXXXXXXXXX   # e.g. v0.14.0
chamber write kops KUBE_PROMETHEUS_ALERT_MANAGER_SLACK_WEBHOOK_URL XXXXXXXXXXXX
chamber write kops KUBE_PROMETHEUS_ALERT_MANAGER_SLACK_CHANNEL XXXXXXXXXXXX
chamber write kops KUBE_PROMETHEUS_ALERT_MANAGER_HOSTNAME XXXXXXXXXXXX   # e.g. alerts.us-west-2.staging.cloudposse.co
chamber write kops KUBE_PROMETHEUS_ALERT_MANAGER_INGRESS XXXXXXXXXXXX   # e.g. ingress.us-west-2.staging.cloudposse.co
chamber write kops KUBE_PROMETHEUS_ALERT_MANAGER_SECRET_NAME XXXXXXXXXXXX   # e.g. alertmanager-general-tls
chamber write kops KUBE_PROMETHEUS_REPLICA_COUNT XXXXXXXXXXXX   # e.g. 4
chamber write kops KUBE_PROMETHEUS_IMAGE_TAG XXXXXXXXXXXX   # e.g. v2.2.1
chamber write kops KUBE_PROMETHEUS_HOSTNAME XXXXXXXXXXXX   # e.g. prometheus.us-west-2.staging.cloudposse.co
chamber write kops KUBE_PROMETHEUS_INGRESS XXXXXXXXXXXX   # e.g. ingress.us-west-2.staging.cloudposse.co
chamber write kops KUBE_PROMETHEUS_SECRET_NAME XXXXXXXXXXXX   # e.g. prometheus-general-tls
