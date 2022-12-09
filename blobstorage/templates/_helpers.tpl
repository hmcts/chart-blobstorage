{{/*
All the common labels needed for the labels sections of the definitions.
*/}}
{{- define "hmcts.blobstorage.labels" }}
app.kubernetes.io/name: {{ template "hmcts.blobstorage.releaseName" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ template "hmcts.blobstorage.releaseName" . }}
{{- end -}}

{{- define "hmcts.blobstorage.releaseName" -}}
{{- if .Values.releaseNameOverride -}}
{{- tpl .Values.releaseNameOverride $ | trunc 53 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 53 -}}
{{- end -}}
{{- end -}}

{{- define "hmcts.blobstorage.storageAccountSha" -}}
{{- include "hmcts.blobstorage.releaseName" . | sha256sum -}}
{{- end -}}

{{- define "hmcts.blobstorage.storageAccountName" -}}
{{- include "hmcts.blobstorage.storageAccountSha" . | trunc -24 -}}
{{- end -}}