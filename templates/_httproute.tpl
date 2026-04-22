{{- define "common.httproute" -}}
{{- range $name, $component := .Values.components }}
{{- $ctx := dict "componentName" $name "component" $component "Release" $.Release "Chart" $.Chart "Values" $.Values }}
{{- if (($component.gateway).enabled) }}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ include "common.component.fullname" $ctx }}
  namespace: {{ $.Values.namespace }}
  labels:
    {{- include "common.component.labels" $ctx | nindent 4 }}
spec:
  parentRefs:
    - name: {{ $component.gateway.gatewayName }}
      namespace: {{ $component.gateway.gatewayNamespace }}
      sectionName: {{ $component.gateway.sectionName | default "https" }}
  hostnames:
    - {{ $component.gateway.hostname }}
  rules:
    - matches:
        - path:
            type: {{ $component.gateway.pathType }}
            value: {{ $component.gateway.path }}
      backendRefs:
        - name: {{ include "common.component.fullname" $ctx }}
          port: {{ $component.service.port }}
{{- end }}
{{- end }}
{{- end }}
