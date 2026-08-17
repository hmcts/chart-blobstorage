{{- define "hmcts.blobstorage.storageAccountName" -}}
{{- include "hmcts.releasename.v3" . | sha256sum | trunc -24 -}}
{{- end -}}