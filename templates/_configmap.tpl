{{- define "common.configmap" -}}
{{- range $name, $component := .Values.components }}
{{- $ctx := dict "componentName" $name "component" $component "Release" $.Release "Chart" $.Chart "Values" $.Values }}
{{- if (($component.configMap).enabled) }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.component.fullname" $ctx }}-files
  namespace: {{ $.Values.namespace }}
  labels:
    {{- include "common.component.labels" $ctx | nindent 4 }}
data:
  {{- range $filename, $content := $component.configMap.files }}
  {{ $filename }}: |
{{ $content | indent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
