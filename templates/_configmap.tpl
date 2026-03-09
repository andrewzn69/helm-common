{{- define "common.configmap" -}}
{{- if ((.Values.configMap).enabled) }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullname" . }}-files
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
data:
  {{- range $filename, $content := .Values.configMap.files }}
  {{ $filename }}: |
{{ $content | indent 4 }}
  {{- end }}
{{- end }}
{{- end }}
