# Talos Proxmox Kubernetes Cluster

A comprehensive Kubernetes cluster running on Talos OS in Proxmox, featuring a complete homelab setup with media services, authentication, monitoring, and productivity applications.

## 🏗️ Cluster Setup

For detailed cluster installation and configuration instructions, see [CLUSTER_SETUP.md](./CLUSTER_SETUP.md).

## 📋 Quick Start

```bash
# Set kubeconfig
export KUBECONFIG=kubeconfig

# Verify cluster status
kubectl get nodes
kubectl get pods --all-namespaces
```

## 🏛️ Infrastructure Components

### Core Infrastructure
- **Talos OS**: Immutable Linux distribution designed for Kubernetes
- **Traefik**: Reverse proxy and load balancer with automatic Let's Encrypt certificates
- **Democratic CSI**: Storage provisioning using TrueNAS (iSCSI for databases, NFS for applications)
- **Sealed Secrets**: Encrypted secret management for GitOps workflows

### Monitoring & Observability
- **Grafana**: Visualization and dashboarding for metrics and logs
- **Mimir**: Long-term metrics storage and querying (Prometheus-compatible)
- **Loki**: Log aggregation and querying system
- **Grafana Alloy**: Unified telemetry collection agent (metrics and logs)

### Authentication & Security
- **Authentik**: Identity provider and single sign-on (SSO) solution
- **Traefik Middleware**: Authentication middleware integration

## 🚀 Deployment Patterns

### Standard Application Deployment
Each application follows a consistent deployment pattern:

```
<application-name>/
├── <application-name>-namespace.yaml        # Kubernetes namespace
├── <application-name>-statefulset.yaml      # Main application deployment
├── <application-name>-service.yaml          # Service definition
├── <application-name>-ingress.yaml          # Traefik ingress rules
├── <application-name>-sealed-secrets.yaml   # Encrypted sensitive configuration (if needed)
```

### Security Considerations
- All applications use dedicated namespaces for isolation
- **Sealed Secrets**: Sensitive configuration is encrypted using [Sealed Secrets](sealed-secrets/README.md) and safely stored in Git
- Regular secrets containing plain text are never committed to the repository
- Ingress routes are configured with appropriate middleware
- Authentication is handled through Authentik where applicable

## 🛠️ Management Commands

### Application Deployment
```bash
# Deploy a specific application
kubectl apply -f application-name/

# Check application status
kubectl get all -n application-namespace

# View logs
kubectl logs -f -n application-namespace deployment/application-name
```

### Cluster Management
```bash
# View cluster resources
kubectl top nodes
kubectl top pods --all-namespaces

# Check Traefik routes
kubectl get ingressroute --all-namespaces
```

## 🔧 Maintenance

### Regular Tasks
- Monitor disk usage across nodes
- Update application images as needed
- Review and rotate secrets periodically
- Backup important data (databases, configurations)
