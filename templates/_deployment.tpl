{{- define "common.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "common.metadataLabels" . | nindent 4 }}
  {{- with .Values.commonAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  replicas: {{ .Values.replicaCount | default 1 }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "common.metadataLabels" . | nindent 8 }}
      {{- with .Values.commonAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    spec:
      securityContext:
        {{- if .Values.podSecurityContext }}
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
        {{- else }}
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
        {{- end }}

      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}

      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}

      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end}}

      {{- if or (((.Values.initContainers).fixPermissions).enabled) ((.Values.initContainers).custom) }}
      initContainers:
        {{- if (((.Values.initContainers).fixPermissions).enabled) }}
        - name: fix-permissions
          image: busybox:latest
          command:
            - sh
            - -c
            - |
              echo "Fixing permissions for {{ .Values.initContainers.fixPermissions.path }}"
              chown -R {{ .Values.initContainers.fixPermissions.uid }}:{{ .Values.initContainers.fixPermissions.gid }} {{ .Values.initContainers.fixPermissions.path }}
              echo "Permissions fixed"
          volumeMounts:
            - name: {{ .Values.initContainers.fixPermissions.volumeName }}
              mountPath: {{ .Values.initContainers.fixPermissions.path }}
        {{- end }}

        {{- with .Values.initContainers.custom }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- end }}

      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- if .Values.securityContext }}
            {{- toYaml .Values.securityContext | nindent 12 }}
            {{- else}}
            runAsNonRoot: true
            runAsUser: 1000
            runAsGroup: 1000
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
            seccompProfile:
              type: RuntimeDefault
            {{- end }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          {{- with .Values.args }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
            {{- if ((.Values.metrics).enabled) }}
            - name: metrics
              containerPort: {{ .Values.metrics.port }}
              protocol: TCP
            {{- end }}

          {{- with .Values.env }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}

          {{- if (((.Values.probes).liveness).enabled) }}
          livenessProbe:
            {{- if eq .Values.probes.liveness.type "httpGet" }}
            httpGet:
              path: {{ .Values.probes.liveness.httpGet.path }}
              port: {{ .Values.probes.liveness.httpGet.port }}
              scheme: {{ .Values.probes.liveness.httpGet.scheme | default "HTTP" }}
            {{- else if eq .Values.probes.liveness.type "tcpSocket" }}
            tcpSocket:
              port: {{ .Values.probes.liveness.tcpSocket.port }}
            {{- else if eq .Values.probes.liveness.type "exec" }}
            exec:
              command:
                {{- toYaml .Values.probes.liveness.exec.command | nindent 16 }}
            {{- end }}
            initialDelaySeconds: {{ .Values.probes.liveness.initialDelaySeconds }}
            periodSeconds: {{ .Values.probes.liveness.periodSeconds }}
            timeoutSeconds: {{ .Values.probes.liveness.timeoutSeconds }}
            successThreshold: {{ .Values.probes.liveness.successThreshold }}
            failureThreshold: {{ .Values.probes.liveness.failureThreshold }}
          {{- end }}

          {{- if (((.Values.probes).readiness).enabled) }}
          readinessProbe:
            {{- if eq .Values.probes.readiness.type "httpGet" }}
            httpGet:
              path: {{ .Values.probes.readiness.httpGet.path }}
              port: {{ .Values.probes.readiness.httpGet.port }}
              scheme: {{ .Values.probes.readiness.httpGet.scheme | default "HTTP" }}
            {{- else if eq .Values.probes.readiness.type "tcpSocket" }}
            tcpSocket:
              port: {{ .Values.probes.readiness.tcpSocket.port }}
            {{- else if eq .Values.probes.readiness.type "exec" }}
            exec:
              command:
                {{- toYaml .Values.probes.readiness.exec.command | nindent 16 }}
            {{- end }}
            initialDelaySeconds: {{ .Values.probes.readiness.initialDelaySeconds }}
            periodSeconds: {{ .Values.probes.readiness.periodSeconds }}
            timeoutSeconds: {{ .Values.probes.readiness.timeoutSeconds }}
            successThreshold: {{ .Values.probes.readiness.successThreshold }}
            failureThreshold: {{ .Values.probes.readiness.failureThreshold }}
          {{- end }}

          {{- if (((.Values.probes).startup).enabled) }}
          startupProbe:
            {{- if eq .Values.probes.startup.type "httpGet" }}
            httpGet:
              path: {{ .Values.probes.startup.httpGet.path }}
              port: {{ .Values.probes.startup.httpGet.port }}
              scheme: {{ .Values.probes.startup.httpGet.scheme | default "HTTP" }}
            {{- else if eq .Values.probes.startup.type "tcpSocket" }}
            tcpSocket:
              port: {{ .Values.probes.startup.tcpSocket.port }}
            {{- else if eq .Values.probes.startup.type "exec" }}
            exec:
              command:
                {{- toYaml .Values.probes.startup.exec.command | nindent 16 }}
            {{- end }}
            initialDelaySeconds: {{ .Values.probes.startup.initialDelaySeconds }}
            periodSeconds: {{ .Values.probes.startup.periodSeconds }}
            timeoutSeconds: {{ .Values.probes.startup.timeoutSeconds }}
            successThreshold: {{ .Values.probes.startup.successThreshold }}
            failureThreshold: {{ .Values.probes.startup.failureThreshold }}
          {{- end }}

          {{- with .Values.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}

          {{- if or ((.Values.volumes).pvc) ((.Values.volumes).nfs) ((.Values.configMap).enabled) }}
          volumeMounts:
            {{- range ((.Values.volumes).pvc) }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
              {{- if .readOnly }}
              readOnly: {{ .readOnly }}
              {{- end }}
            {{- end }}
            {{- range ((.Values.volumes).nfs) }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
              {{- if .readOnly }}
              readOnly: {{ .readOnly }}
              {{- end }}
            {{- end }}
            {{- if ((.Values.configMap).enabled) }}
            - name: config-files
              mountPath: {{ .Values.configMap.mountPath }}
            {{- end }}
          {{- end }}

        {{- if and ((.Values.metrics).enabled) (((.Values.metrics).sidecar).enabled) }}
        - name: metrics-exporter
          image: {{ .Values.metrics.sidecar.image }}
          ports:
            - name: metrics
              containerPort: {{ .Values.metrics.sidecar.port }}
          {{- with .Values.metrics.sidecar.env }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        {{- end }}

      {{- if or ((.Values.volumes).pvc) ((.Values.volumes).nfs) ((.Values.configMap).enabled) }}
      volumes:
        {{- range ((.Values.volumes).pvc) }}
        - name: {{ .name }}
          persistentVolumeClaim:
            claimName: {{ include "common.fullname" $ }}-{{ .name }}
        {{- end}}
        {{- range ((.Values.volumes).nfs) }}
        - name: {{ .name }}
          nfs:
            server: {{ .server }}
            path: {{ .path }}
            readOnly: {{ .readOnly | default false }}
        {{- end }}
        {{- if ((.Values.configMap).enabled) }}
        - name: config-files
          configMap:
            name: {{ include "common.fullname" . }}-files
        {{- end }}
      {{- end}}
{{- end }}
