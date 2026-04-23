{{- define "common.persistentvolumeclaim" -}}
{{- range $name, $component := .Values.components }}
{{- $ctx := dict "componentName" $name "component" $component "Release" $.Release "Chart" $.Chart "Values" $.Values }}
{{- range (($component.volumes).pvc) }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "common.component.fullname" $ctx }}-{{ .name }}
  namespace: {{ $.Values.namespace }}
  labels:
    {{- include "common.component.labels" $ctx | nindent 4 }}
spec:
  accessModes:
    - {{ .accessMode }}
  {{- if .storageClassName }}
  storageClassName: {{ .storageClassName }}
  {{- end }}
  resources:
    requests:
      storage: {{ .size }}
{{- end }}
{{- end }}
{{- end }}
