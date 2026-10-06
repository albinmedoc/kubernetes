# Traefik Installation

This guide covers installing Traefik as an ingress controller with MetalLB for load balancing.

## Tailscale-only access

Traefik listens on port `444` for HTTPS traffic from one Tailscale Layer 3 endpoint named `traefik`. The operator exposes the `traefik-tailscale` Service on port `443`, forwarding TCP to that entrypoint. Traefik terminates TLS using its existing certificates. Applications that require Tailscale use the `tailscale` entrypoint in their routes.

Traefik connects to TrueNAS over HTTPS so its redirect from `/` to `/ui/` preserves HTTPS. TrueNAS currently uses a self-signed certificate; its dedicated `serversTransport` disables backend certificate verification. Browser connections still use Traefik's certificate.

Set internal DNS A and AAAA records for the Tailscale-enabled hostnames to the corresponding Tailscale addresses of the `traefik` endpoint. Do not publish those addresses in public DNS. Connect the client to the tailnet, then use the usual HTTPS URLs. The Tailscale operator's device address is available in the Tailscale admin console or with `tailscale status` on a connected client.

Tailnet policy controls which users and devices can reach the endpoint. The operator's default proxy tag is `tag:k8s`; ensure the policy permits the intended identities.

## Prerequisites

- Kubernetes cluster running
- kubectl configured

## Installation Steps

### 1. Install MetalLB

MetalLB provides LoadBalancer services for bare-metal Kubernetes clusters.

```bash
# Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

# Wait for MetalLB to be ready
kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=90s
```

See [MetalLB Installation](https://metallb.universe.tf/installation/) for more details.

### 2. Configure MetalLB IP Pool

```bash
# Apply MetalLB configuration (IP pool: 192.168.86.2-192.168.86.19)
kubectl apply -f metallb.yaml
```

### 3. Install Traefik CRDs

Traefik requires Custom Resource Definitions for IngressRoute and other resources.

```bash
# Install Traefik CRDs
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.6/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
```

See [Traefik Kubernetes CRD](https://doc.traefik.io/traefik/reference/install-configuration/providers/kubernetes/kubernetes-crd/) for more details.

### 4. Install Traefik

```bash
# Apply all Traefik resources
kubectl apply -f traefik/
```

### 5. Verify Installation

```bash
# Check Traefik pod is running
kubectl get pods -n traefik

# Check LoadBalancer IP assigned
kubectl get svc -n traefik

# Verify MetalLB IP pool
kubectl get ipaddresspool -n metallb-system
```

## Configuration

- **MetalLB IP Range**: `192.168.86.2-192.168.86.19` (configurable in [metallb.yaml](metallb.yaml))
- **Traefik Entrypoints**: 
  - HTTP: port 80 (`web`)
  - HTTPS: port 443 (`websecure`)

## Usage

Create IngressRoute resources to route traffic to your services:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: my-app
  namespace: my-namespace
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`app.example.com`)
      kind: Rule
      services:
        - name: my-app
          port: 80
```

## Troubleshooting

- **LoadBalancer stuck in Pending**: Check MetalLB is running and IP pool is configured
- **503 errors**: Verify backend service is running and IngressRoute matches correctly
- **CRD errors**: Ensure Traefik CRDs are installed before applying IngressRoute resources
