{{/*
Expand the name of the chart.
*/}}
{{- define "echo-server.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "echo-server.fullname" -}}
  {{- if .Values.fullnameOverride }}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- $name := default .Chart.Name .Values.nameOverride }}
    {{- if contains $name .Release.Name }}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "echo-server.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
  helm.sh/chart: {{ include "echo-server.chart" . }}
  {{- if .Chart.AppVersion }}
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  {{- end }}
  app.kubernetes.io/managed-by: {{ .Release.Service }}
*/}}
{{- define "echo-server.labels" -}}
  {{ include "echo-server.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
  app.kubernetes.io/name: {{ include "echo-server.name" . }}
  app.kubernetes.io/instance: {{ .Release.Name }}
*/}}
{{- define "echo-server.selectorLabels" -}}
  app: {{ include "echo-server.fullname" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "echo-server.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create }}
    {{- default (include "echo-server.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
    {{- default "default" .Values.serviceAccount.name }}
  {{- end }}
{{- end }}
