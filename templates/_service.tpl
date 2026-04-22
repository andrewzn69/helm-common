{{- define "common.service" -}}
{{- range $name, $component := .Values.components }}
{{- $ctx := dict "componentName" $name "component" $component "Release" $.Release "Chart" $.Chart "Values" $.Values }}
{{- if ne (($component.service).enabled | toString) "false" }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.component.fullname" $ctx }}
  namespace: {{ $.Values.namespace }}
  labels:
    {{- include "common.component.labels" $ctx | nindent 4 }}
  {{- if or (($component.metrics).enabled) ($component.service.annotations) }}
  annotations:
    {{- if ($component.service.annotations) }}
    {{- toYaml $component.service.annotations | nindent 4 }}
    {{- end }}
    {{- if (($component.metrics).enabled) }}
    {{- toYaml $component.metrics.serviceAnnotations | nindent 4 }}
    {{- end }}
  {{- end }}
spec:
  type: {{ $component.service.type }}
  ports:
    - port: {{ $component.service.port }}
      targetPort: {{ $component.service.targetPort }}
      protocol: {{ $component.service.protocol }}
      name: {{ $component.service.name }}
      {{- if and (or (eq $component.service.type "NodePort") (eq $component.service.type "LoadBalancer")) $component.service.nodePort }}
      nodePort: {{ $component.service.nodePort }}
      {{- end }}

    {{- if (($component.metrics).enabled) }}
    - name: metrics
      port: {{ $component.metrics.port }}
      targetPort: {{ $component.metrics.port }}
      protocol: TCP
    {{- end }}

    {{- range $component.service.additionalPorts }}
    - name: {{ .name }}
      port: {{ .port }}
      targetPort: {{ .targetPort }}
      protocol: {{ .protocol | default "TCP" }}
      {{- if and (or (eq $component.service.type "NodePort") (eq $component.service.type "LoadBalancer")) .nodePort }}
      nodePort: {{ .nodePort }}
      {{- end }}
    {{- end }}

  selector:
    {{- include "common.component.selectorLabels" $ctx | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
