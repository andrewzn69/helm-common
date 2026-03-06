{{- define "common.persistentvolumeclaim" -}}
{{- range .Values.volumes.pvc }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "common.fullname" $ }}-{{ .name }}
  namespace: {{ $.Values.namespace }}
  labels:
    {{- include "common.labels" $ | nindent 4 }}
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
