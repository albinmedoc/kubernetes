# Talos Kubernetes Cluster Setup

This document contains instructions for setting up a Talos Kubernetes cluster on Proxmox.

## Prerequisites

- Proxmox VE environment
- Homebrew (for macOS)

## Initial Cluster Setup

1. **Install Talos CLI**
   ```bash
   brew install talosctl
   ```

2. **Generate cluster configuration**
   ```bash
   talosctl gen config talos-proxmox-cluster https://<IP_OF_CONTROL_PLANE>:6443 --output-dir talos-proxmox-cluster
   cd talos-proxmox-cluster
   ```

3. **Apply configurations to nodes**
   ```bash
   # Apply control plane configuration
   talosctl apply-config --insecure --nodes <IP_OF_CONTROL_PLANE> --file controlplane.yaml
   
   # Apply worker node configuration
   talosctl apply-config --insecure --nodes <IP_OF_WORKER_NODE> --file worker.yaml
   ```

4. **Configure Talos client**
   ```bash
   export TALOSCONFIG="talosconfig"
   talosctl config endpoint <IP_OF_CONTROL_PLANE>
   talosctl config node <IP_OF_CONTROL_PLANE>
   ```

5. **Bootstrap the cluster**
   ```bash
   talosctl bootstrap
   ```

6. **Generate kubeconfig**
   ```bash
   talosctl kubeconfig .
   export KUBECONFIG=kubeconfig
   ```

## Adding New Worker Nodes

To add additional worker nodes to the cluster:

```bash
talosctl apply-config --insecure --nodes <IP_OF_NEW_WORKER_NODE> --file worker.yaml
```

## Accessing the Cluster

After setup, you can access your cluster using kubectl:

```bash
export KUBECONFIG=kubeconfig
kubectl get nodes
```

## Troubleshooting

- Ensure all nodes have network connectivity
- Check Proxmox VM configurations match Talos requirements
- Verify firewall rules allow required ports (6443, 50000, 50001)
