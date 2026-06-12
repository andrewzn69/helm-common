{{/*
  Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
*/}}
{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Release.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
  Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels
*/}}
{{- define "common.labels" -}}
helm.sh/chart: {{ include "common.chart" . }}
{{ include "common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
  Selector labels
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Metadata labels (includes component and part-of)
*/}}
{{- define "common.metadataLabels" -}}
{{- include "common.labels" . }}
{{- if .Values.component }}
app.kubernetes.io/component: {{ .Values.component }}
{{- end }}
{{- if .Values.partOf}}
app.kubernetes.io/part-of: {{ .Values.partOf }}
{{- end }}
{{- end }}

{{/*
  ### MULTI-COMPONENT HELPERS

  Context is a dist, not the default Helm context:
  (dict "componentName" $name "component" $component "Release" $.Release "Chart" $.Chart "Values" $.Values)
*/}}

{{/*
  Resource name for a component.
  If the component name is already part of the release name, skip the suffix
  to avoid ugly duplication (e.g. jellyfin-jellyfin -> jellyfin).
*/}}
{{- define "common.component.fullname" -}}
{{- if contains .componentName .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .componentName | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
  Selector labels - includes componentName to make each Deployment's selector unique.
  Without this, multiple Deployments in one chart would have identical selectors
  and Kubernetes would reject them
*/}}
{{- define "common.component.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .componentName }}
{{- end }}

{{/*
  Full label set for a component
*/}}
{{- define "common.component.labels" -}}
helm.sh/chart: {{ include "common.chart" (dict "Chart" .Chart) }}
{{ include "common.component.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end }}
