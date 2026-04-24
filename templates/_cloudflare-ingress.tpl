{{- define "common.cloudflare-ingress" -}}
{{- $hostmap := dict -}}
{{- range $name, $component := .Values.components -}}
  {{- $ctx := dict "componentName" $name "component" $component "Release" $.Release "Chart" $.Chart "Values" $.Values -}}
  {{- if (($component.cloudflare).enabled) -}}
    {{- $hostname := $component.cloudflare.hostname -}}
    {{- $existing := index $hostmap $hostname | default list -}}
    {{- range $component.cloudflare.paths -}}
      {{- $entry := dict "path" .path "pathType" .pathType "serviceName" (include "common.component.fullname" $ctx) "port" ($component.service.port | int) -}}
      {{- $existing = append $existing $entry -}}
    {{- end -}}
    {{- $_ := set $hostmap $hostname $existing -}}
  {{- end -}}
{{- end -}}
{{- range $hostname, $paths := $hostmap }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $.Release.Name }}-{{ $hostname | replace "." "-" | trunc 40 | trimSuffix "-" }}
  namespace: {{ $.Values.namespace }}
  labels:
    {{- include "common.labels" (dict "Chart" $.Chart "Release" $.Release "Values" $.Values) | nindent 4 }}
spec:
  ingressClassName: cloudflare-tunnel
  rules:
    - host: {{ $hostname }}
      http:
        paths:
          {{- range $paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ .serviceName }}
                port:
                  number: {{ .port }}
          {{- end }}
{{- end }}
{{- end }}
