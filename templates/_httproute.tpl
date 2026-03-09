{{- define "common.httproute" -}}
{{- if ((.Values.gateway).enabled) }}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  parentRefs:
    - name: {{ .Values.gateway.gatewayName }}
      namespace: {{ .Values.gateway.gatewayNamespace }}
  hostnames:
    - {{ .Values.gateway.hostname }}
  rules:
    - matches:
        - path:
            type: {{ .Values.gateway.pathType }}
            value: {{ .Values.gateway.path }}
      backendRefs:
        - name: {{ include "common.fullname" . }}
          port: {{ .Values.service.port }}
{{- end }}
{{- end }}
