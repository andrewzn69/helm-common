{{- define "common.deployment" -}}
{{- range $name, $component := .Values.components }}
{{- $ctx := dict "componentName" $name "component" $component "Release" $.Release "Chart" $.Chart "Values" $.Values }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.component.fullname" $ctx }}
  namespace: {{ $.Values.namespace }}
  labels:
    {{- include "common.component.labels" $ctx | nindent 4 }}
  {{- with $component.commonAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  replicas: {{ $component.replicaCount | default 1 }}
  selector:
    matchLabels:
      {{- include "common.component.selectorLabels" $ctx | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "common.component.labels" $ctx | nindent 8 }}
      {{- with $component.commonAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    spec:
      securityContext:
        {{- if $component.podSecurityContext }}
        {{- toYaml $component.podSecurityContext | nindent 8 }}
        {{- else }}
        fsGroup: 10001
        seccompProfile:
          type: RuntimeDefault
        {{- end }}

      {{- with $component.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}

      {{- with $component.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}

      {{- with $component.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end}}

      {{- if or ((($component.initContainers).fixPermissions).enabled) (($component.initContainers).custom) }}
      initContainers:
        {{- if ((($component.initContainers).fixPermissions).enabled) }}
        - name: fix-permissions
          image: busybox:latest
          command:
            - sh
            - -c
            - |
              chown -R {{ $component.initContainers.fixPermissions.uid }}:{{ $component.initContainers.fixPermissions.gid }} {{ $component.initContainers.fixPermissions.path }}
          volumeMounts:
            - name: {{ $component.initContainers.fixPermissions.volumeName }}
              mountPath: {{ $component.initContainers.fixPermissions.path }}
        {{- end }}
        {{- with $component.initContainers.custom }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- end }}

      containers:
        - name: {{ $name }}
          securityContext:
            {{- if $component.securityContext }}
            {{- toYaml $component.securityContext | nindent 12 }}
            {{- else}}
            runAsNonRoot: true
            runAsUser: 10001
            runAsGroup: 10001
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
            seccompProfile:
              type: RuntimeDefault
            {{- end }}
          image: "{{ $component.image.repository }}:{{ $component.image.tag }}"
          imagePullPolicy: {{ $component.image.pullPolicy | default "IfNotPresent" }}
          {{- with $component.command }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $component.args }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if ne (($component.service).enabled | toString) "false" }}
          ports:
            - name: http
              containerPort: {{ $component.service.targetPort }}
              protocol: TCP
            {{- if (($component.metrics).enabled) }}
            - name: metrics
              containerPort: {{ $component.metrics.port }}
              protocol: TCP
            {{- end }}
          {{- end }}

          {{- if or $.Values.globalEnv $component.env }}
          env:
            {{- with $.Values.globalEnv }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
            {{- with $component.env }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- end }}

          {{- if ((($component.probes).liveness).enabled) }}
          livenessProbe:
            {{- if eq $component.probes.liveness.type "httpGet" }}
            httpGet:
              path: {{ $component.probes.liveness.httpGet.path }}
              port: {{ $component.probes.liveness.httpGet.port }}
              scheme: {{ $component.probes.liveness.httpGet.scheme | default "HTTP" }}
            {{- else if eq $component.probes.liveness.type "tcpSocket" }}
            tcpSocket:
              port: {{ $component.probes.liveness.tcpSocket.port }}
            {{- else if eq $component.probes.liveness.type "exec" }}
            exec:
              command:
                {{- toYaml $component.probes.liveness.exec.command | nindent 16 }}
            {{- end }}
            initialDelaySeconds: {{ $component.probes.liveness.initialDelaySeconds }}
            periodSeconds: {{ $component.probes.liveness.periodSeconds }}
            timeoutSeconds: {{ $component.probes.liveness.timeoutSeconds }}
            successThreshold: {{ $component.probes.liveness.successThreshold }}
            failureThreshold: {{ $component.probes.liveness.failureThreshold }}
          {{- end }}

          {{- if ((($component.probes).readiness).enabled) }}
          readinessProbe:
            {{- if eq $component.probes.readiness.type "httpGet" }}
            httpGet:
              path: {{ $component.probes.readiness.httpGet.path }}
              port: {{ $component.probes.readiness.httpGet.port }}
              scheme: {{ $component.probes.readiness.httpGet.scheme | default "HTTP" }}
            {{- else if eq $component.probes.readiness.type "tcpSocket" }}
            tcpSocket:
              port: {{ $component.probes.readiness.tcpSocket.port }}
            {{- else if eq $component.probes.readiness.type "exec" }}
            exec:
              command:
                {{- toYaml $component.probes.readiness.exec.command | nindent 16 }}
            {{- end }}
            initialDelaySeconds: {{ $component.probes.readiness.initialDelaySeconds }}
            periodSeconds: {{ $component.probes.readiness.periodSeconds }}
            timeoutSeconds: {{ $component.probes.readiness.timeoutSeconds }}
            successThreshold: {{ $component.probes.readiness.successThreshold }}
            failureThreshold: {{ $component.probes.readiness.failureThreshold }}
          {{- end }}

          {{- if ((($component.probes).startup).enabled) }}
          startupProbe:
            {{- if eq $component.probes.startup.type "httpGet" }}
            httpGet:
              path: {{ $component.probes.startup.httpGet.path }}
              port: {{ $component.probes.startup.httpGet.port }}
              scheme: {{ $component.probes.startup.httpGet.scheme | default "HTTP" }}
            {{- else if eq $component.probes.startup.type "tcpSocket" }}
            tcpSocket:
              port: {{ $component.probes.startup.tcpSocket.port }}
            {{- else if eq $component.probes.startup.type "exec" }}
            exec:
              command:
                {{- toYaml $component.probes.startup.exec.command | nindent 16 }}
            {{- end }}
            initialDelaySeconds: {{ $component.probes.startup.initialDelaySeconds }}
            periodSeconds: {{ $component.probes.startup.periodSeconds }}
            timeoutSeconds: {{ $component.probes.startup.timeoutSeconds }}
            successThreshold: {{ $component.probes.startup.successThreshold }}
            failureThreshold: {{ $component.probes.startup.failureThreshold }}
          {{- end }}

          {{- with $component.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}

          {{- if or (($component.volumes).pvc) (($component.volumes).nfs) (($component.volumes).emptyDir) (($component.configMap).enabled) }}
          volumeMounts:
            {{- range (($component.volumes).pvc) }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
              {{- if .readOnly }}
              readOnly: {{ .readOnly }}
              {{- end }}
            {{- end }}
            {{- range (($component.volumes).nfs) }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
              {{- if .readOnly }}
              readOnly: {{ .readOnly }}
              {{- end }}
            {{- end }}
            {{- range (($component.volumes).emptyDir) }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
            {{- end }}
            {{- if (($component.configMap).enabled) }}
            - name: config-files
              mountPath: {{ $component.configMap.mountPath }}
              {{- if $component.configMap.subPath }}
              subPath: {{ $component.configMap.subPath }}
            {{- end }}
          {{- end }}

        {{- if and (($component.metrics).enabled) ((($component.metrics).sidecar).enabled) }}
        - name: metrics-exporter
          image: {{ $component.metrics.sidecar.image }}
          ports:
            - name: metrics
              containerPort: {{ $component.metrics.sidecar.port }}
          {{- with $component.metrics.sidecar.env }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        {{- end }}

      {{- if or (($component.volumes).pvc) (($component.volumes).nfs) (($component.volumes).emptyDir) (($component.configMap).enabled) }}
      volumes:
        {{- range (($component.volumes).pvc) }}
        - name: {{ .name }}
          persistentVolumeClaim:
            claimName: {{ include "common.component.fullname" $ctx }}-{{ .name }}
        {{- end}}
        {{- range (($component.volumes).nfs) }}
        - name: {{ .name }}
          nfs:
            server: {{ .server }}
            path: {{ .path }}
            readOnly: {{ .readOnly | default false }}
        {{- end }}
        {{- range (($component.volumes).emptyDir) }}
        - name: {{ .name }}
          emptyDir: {}
        {{- end }}
        {{- if (($component.configMap).enabled) }}
        - name: config-files
          configMap:
            name: {{ include "common.component.fullname" $ctx }}-files
        {{- end }}
      {{- end}}
{{- end }}
{{- end }}
