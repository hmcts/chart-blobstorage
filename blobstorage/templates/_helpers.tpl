{{- define "hmcts.blobstorage.storageAccountName" -}}
{{- $azureName := .Values.setup.azureName | default dict -}}
{{- if $azureName -}}
{{ .Values.setup.azureName }}
{{- else -}}
{{- include "hmcts.releasename.v2" . | sha256sum | trunc -24 -}}
{{- end -}}
{{- end -}}