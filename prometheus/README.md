# Prometheus Operator

This directory contains the configuration for the Prometheus Operator, which provides Kubernetes native deployment and management of Prometheus and related monitoring components.

## Overview

The Prometheus Operator creates/configures/manages Prometheus clusters atop Kubernetes. It provides:

- **Prometheus**: Time-series database for metrics collection
- **ServiceMonitors**: Custom resources to define how to monitor Kubernetes services
- **PodMonitors**: Custom resources to monitor Kubernetes pods
- **PrometheusRules**: Custom resources to define alerting and recording rules
- **AlertManager**: Handles alerts from Prometheus and routes them to receivers

## Installation

### Deploy Prometheus Operator

Apply the operator bundle to install all required CRDs and components:

```bash
kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.87.0/bundle.yaml
```

This installs:
- Custom Resource Definitions (CRDs) for Prometheus, ServiceMonitor, PodMonitor, etc.
- Prometheus Operator deployment
- RBAC resources (ClusterRoles, ClusterRoleBindings, ServiceAccounts)

### Verify Installation

Check that the operator is running:

```bash
# Check operator pod status
kubectl get pods -n default -l app.kubernetes.io/name=prometheus-operator

# Verify CRDs are installed
kubectl get crd | grep monitoring.coreos.com
```

**Note**: Both the operator and Prometheus instances run in the `default` namespace.

Expected CRDs:
- `alertmanagerconfigs.monitoring.coreos.com`
- `alertmanagers.monitoring.coreos.com`
- `podmonitors.monitoring.coreos.com`
- `probes.monitoring.coreos.com`
- `prometheusagents.monitoring.coreos.com`
- `prometheuses.monitoring.coreos.com`
- `prometheusrules.monitoring.coreos.com`
- `scrapeconfigs.monitoring.coreos.com`
- `servicemonitors.monitoring.coreos.com`
- `thanosrulers.monitoring.coreos.com`

## Deploying Prometheus

After installing the operator, deploy a Prometheus instance and configure monitoring.

### Option 1: Deploy with ArgoCD (Recommended)

ArgoCD will automatically sync changes from git and keep your cluster in sync:

```bash
# Deploy the ArgoCD Application
kubectl apply -f argocd/applications/prometheus.yaml

# Check ArgoCD sync status
argocd app get prometheus
argocd app sync prometheus
```

**Benefits**:
- ✅ Auto-sync on git commits
- ✅ Drift detection and self-healing
- ✅ Easy rollbacks
- ✅ GitOps best practices

### Option 2: Manual Deployment

Apply the manifests in order:

```bash
# Create RBAC (namespace not needed - using default)
kubectl apply -f prometheus/prometheus-account.yaml
kubectl apply -f prometheus/prometheus-role.yaml
kubectl apply -f prometheus/prometheus-role-binding.yaml

# Deploy Prometheus instance
kubectl apply -f prometheus/prometheus-instance.yaml

# Create service and ingress
kubectl apply -f prometheus/prometheus-service.yaml
kubectl apply -f prometheus/prometheus-ingress.yaml
```

**Before deploying**, review and update:
- `prometheus-instance.yaml`: Adjust storage class name to match your cluster
- `prometheus-ingress.yaml`: Change domain name to your actual domain

### Step 2: Verify Prometheus is Running

```bash
# Check Prometheus pod
kubectl get pods -n default -l app.kubernetes.io/name=prometheus

# Check Prometheus service
kubectl get svc -n default prometheus

# View Prometheus logs
kubectl logs -n default -l app.kubernetes.io/name=prometheus -f
```

### Step 3: Deploy ServiceMonitors

ServiceMonitors tell Prometheus what to scrape. Deploy the Kubernetes system monitors:

```bash
# Monitor Kubernetes components (API server, kubelet, cAdvisor)
kubectl apply -f prometheus/servicemonitor-kubernetes.yaml
```

### Creating ServiceMonitors for Your Applications

For each application you want to monitor:

1. Ensure your application exposes metrics (usually on `/metrics` endpoint)
2. Create a ServiceMonitor using [servicemonitor.yaml.example](servicemonitor.yaml.example) as a template
3. Update the namespace, service labels, and port name to match your application
4. Apply with label `prometheus: "true"` so Prometheus discovers it

**Example**: If you have a service named `my-app` in namespace `production` with a metrics port:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
  namespace: default
  labels:
    prometheus: "true"
spec:
  namespaceSelector:
    matchNames:
    - production
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

### Access Prometheus UI

Once deployed, access Prometheus:

- **Via Port Forward**:
  ```bash
  kubectl port-forward -n default svc/prometheus 9090:9090
  ```
  Then open http://localhost:9090

## Resources

- [Prometheus Operator Documentation](https://prometheus-operator.dev/)
- [Getting Started Guide](https://prometheus-operator.dev/docs/prologue/quick-start/)
- [API Documentation](https://prometheus-operator.dev/docs/api-reference/)

## Maintenance

### Upgrade Prometheus Operator

To upgrade to a newer version:

```bash
# Replace vX.Y.Z with the desired version
kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/download/vX.Y.Z/bundle.yaml
```
