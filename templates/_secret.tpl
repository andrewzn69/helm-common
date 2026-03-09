{{- define "common.secret" -}}
{{- if ((.Values.secrets).enabled) }}
{{- if eq .Values.secrets.type "infisical" }}
---
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  hostAPI: {{ .Values.secrets.infisical.hostAPI }}
 
  authentication:
    universalAuth:
      credentialsRef:
        secretName: {{ .Values.secrets.infisical.auth.credentialsSecretName }}
        secretNamespace: {{ .Values.secrets.infisical.auth.credentialsSecretNamespace }}
      secretsScope:
        projectSlug: {{ .Values.secrets.infisical.projectSlug | required ".Values.secrets.infisical.projectSlug is required" }}
        envSlug: {{ .Values.secrets.infisical.envSlug }}
        secretsPath: {{ .Values.secrets.infisical.secretsPath | required ".Values.secrets.infisical.secretsPath is required" }}

  managedKubeSecretReferences:
    - secretName: {{ include "common.fullname" . }}
      secretNamespace: {{ .Values.namespace }}
      creationPolicy: {{ .Values.secrets.infisical.managedSecret.creationPolicy }}
{{- end }}
{{- end }}
{{- end }}
