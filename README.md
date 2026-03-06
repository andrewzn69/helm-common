# Common Helm Chart

Reusable library chart that provides templates for all application

## Usage

Add as a dependency in you application chart

```yaml
# Chart.yaml
apiVersion: v2
name: my-app
version: 1.0.0
dependencies:
  - name: common
    version: 1.0.0
    repository: oci://ghcr.io/andrewzn69
```
Then import templates:

```yaml
# templates/deployment.yaml
{{- include "common.deployment" . }}
```

Available templates:

- `common.deployment` - Deployment with init containers, probes, volumes
- `common.service` - Service with multiple ports support
- `common.persistentvolumeclaim` - PVC for local-path or other StorageClass
- `common.secret` - Infisical secret integration
- `common.configmap` - ConfigMap for files
- `common.httproute` - Gateway API HTTPRoute
- `common.cloudflare-ingress` - Cloudflare Tunnel ingress
