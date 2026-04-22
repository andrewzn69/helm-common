{{- define "common.cloudflare-ingress" -}}
{{- range $name, $component := .Values.components }}
{{- $ctx := dict "componentName" $name "component" $component "Release" $.Release "Chart" $.Chart "Values" $.Values }}
{{- if (($component.cloudflare).enabled) }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "common.component.fullname" $ctx }}
  namespace: {{ $.Values.namespace }}
  labels:
    {{- include "common.component.labels" $ctx | nindent 4 }}
spec:
  ingressClassName: cloudflare-tunnel
  rules:
    - host: {{ $component.cloudflare.hostname }}
      http:
        paths:
          - path: {{ $component.cloudflare.path }}
            pathType: {{ $component.cloudflare.pathType }}
            backend:
              service:
                name: {{ include "common.component.fullname" $ctx }}
                port:
                  number: {{ $component.service.port }}
{{- end }}
{{- end }}
{{- end }}
