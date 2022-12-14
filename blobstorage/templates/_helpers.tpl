{{- define "hmcts.blobstorage.storageAccountName" -}}
{{- include "hmcts.releasename.v2" . | sha256sum | trunc -24 -}}
{{- end -}}