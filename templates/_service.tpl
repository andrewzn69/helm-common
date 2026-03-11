{{- define "common.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- if or ((.Values.metrics).enabled) (.Values.service.annotations) }}
  annotations:
    {{- if (.Values.service.annotations) }}
    {{- toYaml .Values.service.annotations | nindent 4 }}
    {{- end }}
    {{- if ((.Values.metrics).enabled) }}
    {{- toYaml .Values.metrics.serviceAnnotations | nindent 4 }}
    {{- end }}
  {{- end }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: {{ .Values.service.protocol }}
      name: {{ .Values.service.name }}
      {{- if and (or (eq .Values.service.type "NodePort") (eq .Values.service.type "LoadBalancer")) .Values.service.nodePort }}
      nodePort: {{ .Values.service.nodePort }}
      {{- end }}

    {{- if ((.Values.metrics).enabled) }}
    - name: metrics
      port: {{ .Values.metrics.port }}
      targetPort: {{ .Values.metrics.port }}
      protocol: TCP
    {{- end }}

    {{- range .Values.service.additionalPorts }}
    - name: {{ .name }}
      port: {{ .port }}
      targetPort: {{ .targetPort }}
      protocol: {{ .protocol | default "TCP" }}
      {{- if and (or (eq $.Values.service.type "NodePort") (eq $.Values.service.type "LoadBalancer")) .nodePort }}
      nodePort: {{ .nodePort }}
      {{- end }}
    {{- end }}

  selector:
    {{- include "common.selectorLabels" . | nindent 4 }}
{{- end }}
