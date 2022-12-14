{{- define "hmcts.blobstorage.releaseName" -}}
{{- if .Values.releaseNameOverride -}}
{{- tpl .Values.releaseNameOverride $ | trunc 53 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 53 -}}
{{- end -}}
{{- end -}}

{{- define "hmcts.blobstorage.storageAccountName" -}}
{{- include "hmcts.blobstorage.releaseName" . | sha256sum | trunc -24 -}}
{{- end -}}