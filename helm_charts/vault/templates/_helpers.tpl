{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
We adjust by 24 to allow for component names in the resource name
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 39 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a value that contains the vault -tls-skip-verify flag if we should skip TLS verification for vault
This is used to skip verification when using self-signed certs or the LetsEncrypt staging environment
*/}}
{{- define "tls_skip_verify" -}}
  {{ if (or (not .Values.Vault.Tls.LetsEncrypt.Enabled) (eq .Values.Vault.Tls.LetsEncrypt.Environment "stage")) }}
    {{- print "--tls-skip-verify" -}}
  {{ else }}
    {{- print "" -}}
  {{ end }}
{{- end -}}
