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
- **Traefik**: Reverse proxy and load balancer with automatic service discovery
- **MetalLB**: Bare-metal load balancer for on-premises clusters
- **Metrics Server**: Cluster-wide resource usage metrics

## 🚀 Deployment Patterns

### Standard Application Deployment
Each application follows a consistent deployment pattern:

```
application-name/
├── namespace.yaml          # Kubernetes namespace
├── statefulset.yaml       # Main application deployment
├── service.yaml           # Service definition
├── ingress.yaml          # Traefik ingress rules
├── secrets.yaml          # Sensitive configuration (if needed)
```

### Security Considerations
- All applications use dedicated namespaces for isolation
- Secrets are properly managed and not committed to repository
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

# Monitor services with Gatus
kubectl port-forward -n gatus svc/gatus 8080:80
```

## 🔧 Maintenance

### Regular Tasks
- Monitor disk usage across nodes
- Update application images as needed
- Review and rotate secrets periodically
- Backup important data (databases, configurations)
