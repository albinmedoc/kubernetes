# GitHub Copilot Instructions for Kubernetes Application Deployment

## Overview
This repository contains Kubernetes manifests for a Talos OS cluster running on Proxmox. When creating new application deployments, follow the standardized patterns described below.

## Standard Application Structure

Each application follows this consistent deployment pattern:

```
<application-name>/
├── <application-name>-namespace.yaml        # Kubernetes namespace
├── <application-name>-deployment.yaml       # Main application (or statefulset for databases)
├── <application-name>-service.yaml          # Service definition
├── <application-name>-ingress.yaml          # Traefik ingress rules (web services only)
├── <application-name>-pvc.yaml              # Persistent volume claim (if needed)
├── <application-name>-secrets.yaml.example  # Example secrets template (if needed)
├── <application-name>-configmap.yaml        # Non-sensitive configuration (if needed)
```

## Deployment Guidelines

### 1. Namespace
- **Always create**: Every application must have a dedicated namespace
- **Naming**: Use lowercase with hyphens (e.g., `n8n`, `postgres17`, `paperless-ngx`)
- **Labels**: Include standard labels:
  ```yaml
  labels:
    app.kubernetes.io/name: <app-name>
    app.kubernetes.io/component: <component-type>
    app.kubernetes.io/managed-by: kubectl
  ```

### 2. Deployment vs StatefulSet
- **Use StatefulSet for**:
  - Databases (PostgreSQL, MariaDB, Redis, etc.)
  - Applications requiring stable network identities
  - Applications requiring ordered deployment/scaling
  - Include `serviceName: <app-name>` in StatefulSet spec

- **Use Deployment for**:
  - Stateless applications
  - Web services
  - Worker processes
  - All other applications

### 3. Persistent Storage
When the application requires persistent storage:

- **Use `truenas-iscsi` for**:
  - Databases (PostgreSQL, MariaDB, Redis)
  - Applications requiring high performance
  - Single-node access (ReadWriteOnce)

- **Use `truenas-nfs` for**:
  - Web applications
  - File storage services
  - Media servers
  - All non-database applications

**PVC Template**:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: <app-name>
  namespace: <namespace>
  labels:
    app.kubernetes.io/name: <app-name>
    app.kubernetes.io/component: <component-type>
    app.kubernetes.io/managed-by: kubectl
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: truenas-iscsi  # or truenas-nfs for non-databases
  resources:
    requests:
      storage: <size>Gi
```

### 4. Service Configuration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <app-name>
  namespace: <namespace>
  labels:
    app.kubernetes.io/name: <app-name>
    app.kubernetes.io/component: <component-type>
    app.kubernetes.io/managed-by: kubectl
spec:
  selector:
    app.kubernetes.io/name: <app-name>
    app.kubernetes.io/component: <component-type>
  ports:
    - protocol: TCP
      port: <port>
      targetPort: <port>
```

### 5. Ingress Configuration
**Create ingress ONLY for web services that need external access**

Use Traefik IngressRoute:
```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: <app-name>
  namespace: <namespace>
  labels:
    app.kubernetes.io/name: <app-name>
    app.kubernetes.io/component: ingress
    app.kubernetes.io/managed-by: kubectl
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`<app-name>.albinmedoc.se`)
      kind: Rule
      services:
        - name: <app-name>
          port: <port>
      # Optional: Add authentication middleware
      # middlewares:
      #   - name: authentik
      #     namespace: authentik
```

### 6. Secrets Management
For applications requiring sensitive configuration:

`<app-name>-secrets.yaml.example` - Template (committed to Git):
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <app-name>-secrets
  namespace: <namespace>
type: Opaque
stringData:
  KEY_NAME: "example-value"
  ANOTHER_KEY: "example-value"
```

**Note**: Never commit plain `<app-name>-secrets.yaml` files to Git!

### 7. ConfigMap
For non-sensitive configuration:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: <app-name>-config
  namespace: <namespace>
  labels:
    app.kubernetes.io/name: <app-name>
    app.kubernetes.io/component: configuration
    app.kubernetes.io/managed-by: kubectl
data:
  KEY_NAME: "value"
```

### 8. Resource Limits
Always include resource requests and limits:
```yaml
resources:
  limits:
    cpu: 1000m      # Adjust based on application needs
    memory: 1Gi     # Adjust based on application needs
  requests:
    cpu: 200m       # Minimum required
    memory: 256Mi   # Minimum required
```

### 9. Standard Labels
Apply these labels consistently across all resources:
```yaml
labels:
  app.kubernetes.io/name: <app-name>
  app.kubernetes.io/component: <component-type>  # e.g., database, web, api, worker
  app.kubernetes.io/managed-by: kubectl
```

## Workflow for Creating New Applications

When given an application request (e.g., a Docker Hub link or application name):

1. **Research the application**:
   - Identify required ports
   - Determine storage requirements
   - Check for environment variables/configuration needs
   - Identify if it's a database or web service

2. **Create the namespace file first**

3. **Determine deployment type**:
   - Database/stateful → StatefulSet
   - Other → Deployment

4. **Add persistent storage if needed**:
   - Database → `truenas-iscsi`
   - Non-database → `truenas-nfs`

5. **Create service and ingress ONLY if it's a web service**

6. **Add secrets/configmap based on application requirements**

7. **Set appropriate resource limits based on application type**

8. **Use consistent naming and labeling**

## Example: Creating a New Web Application

If asked to create manifests for "Uptime Kuma" (a monitoring tool):

1. Create `uptime-kuma-namespace.yaml`
2. Create `uptime-kuma-deployment.yaml` (not a database, so Deployment)
3. Create `uptime-kuma-pvc.yaml` (with `truenas-nfs` storage class)
4. Create `uptime-kuma-service.yaml` (it's a web service)
5. Create `uptime-kuma-ingress.yaml` (needs external access)
6. If it needs configuration, create configmap or secrets files

## Important Notes

- **Domain**: All ingress routes use the domain `albinmedoc.se`
- **TLS**: All ingress routes use the `websecure` entryPoint (HTTPS)
- **Authentication**: Consider if the service needs Authentik middleware for authentication
- **Init containers**: Add volume permission fixes if the application has permission issues
- **Image versions**: Use specific version tags, not `latest`
- **Storage sizes**: Use reasonable defaults (5-10Gi for apps, 10-20Gi for databases)

## Questions to Ask When Details Are Missing

If the application requirements are unclear, ask:
1. "Is this a database or stateful application?" (determines StatefulSet vs Deployment)
2. "Does this need web access?" (determines if service/ingress are needed)
3. "What port does the application use?"
4. "Does it require persistent storage?"
5. "Are there any required environment variables or secrets?"

## Reference Examples

For complete examples, refer to these existing applications:
- **Web application**: `n8n/` - Shows deployment, PVC, service, ingress, secrets
- **Database**: `databases/postgres17/` - Shows StatefulSet with iSCSI storage
- **With authentication**: `authentik/` - Shows middleware configuration
- **Simple service**: `portainer/portainer-web/` - Basic web service setup
