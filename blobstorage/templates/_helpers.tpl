{{- define "hmcts.blobstorage.storageAccountName" -}}
{{- .Values.azureName | default (include "hmcts.releasename.v3" . | sha256sum | trunc -24) | trim -}}
{{- end -}}