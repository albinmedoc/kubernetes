# Kubernetes Cluster Setup - k8-homelab

This documentation describes the setup of a Kubernetes cluster using Talos Linux.

## Cluster Information

- **Cluster Name**: k8-homelab
- **Control Plane Endpoint**: https://192.168.86.147:6443
- **Kubernetes Version**: v1.33.1
- **Talos Linux Version**: v1.12.4
- **Talos Linux**: Used for both control plane and worker nodes

## Talos Linux Image Factory

This cluster uses a custom Talos Linux image built with the [Talos Linux Image Factory](https://factory.talos.dev/).

### Custom Image Details

- **Image URL**: `factory.talos.dev/metal-installer/c9078f9419961640c712a8bf2bb9174933dfcf1da383fd8ea2b7dc21493f8bac:v1.12.4`
- **Image ID**: c9078f9419961640c712a8bf2bb9174933dfcf1da383fd8ea2b7dc21493f8bac

### System Extensions

The following system extensions are included in the custom image:

1. **siderolabs/qemu-guest-agent**
   - Provides QEMU guest agent functionality for better VM integration
   - Enables communication between the host and guest for monitoring and management

2. **siderolabs/iscsi-tools**
   - Adds iSCSI initiator support
   - Required for iSCSI-based storage solutions

### Upgrading with Custom Image

To upgrade the cluster to the custom image, each node must be upgraded separately:

#### Upgrade Control Plane Node

```bash
talosctl upgrade --nodes $CONTROL_PLANE_IP \
  --image factory.talos.dev/metal-installer/dc7b152cb3ea99b821fcb7340ce7168313ce393d663740b791c36f6e95fc8586:v1.12.4 \
  --talosconfig=./talosconfig
```

#### Upgrade Worker Nodes

```bash
for ip in "${WORKER_IP[@]}"; do
    echo "Upgrading worker node: $ip"
    talosctl upgrade --nodes "$ip" \
      --image factory.talos.dev/metal-installer/dc7b152cb3ea99b821fcb7340ce7168313ce393d663740b791c36f6e95fc8586:v1.12.4 \
      --talosconfig=./talosconfig
done
```

## Node Configuration

### Control Plane Node
- **IP Address**: 192.168.86.147
- **Node Name**: talos-46y-tj6
- **Role**: control-plane
- **Disk**: /dev/sda (34 GB, virtio)

### Worker Nodes
1. **Node 1**
   - **IP Address**: 192.168.86.170
   - **Node Name**: talos-cwm-ls3
   - **Role**: worker

2. **Node 2**
   - **IP Address**: 192.168.86.27
   - **Node Name**: talos-j7g-w2m
   - **Role**: worker

## Installation Steps

### 1. Define Environment Variables

```bash
export CONTROL_PLANE_IP=192.168.86.147
export WORKER_IP=("192.168.86.170" "192.168.86.27")
export CLUSTER_NAME=k8-homelab
export DISK_NAME=sda
```

### 2. Verify Disks

Check available disks on the control plane node:

```bash
talosctl get disks --insecure --nodes $CONTROL_PLANE_IP
```

This showed that `/dev/sda` (34 GB) is available for installation.

### 3. Generate Configuration Files

Create Talos configuration files for the cluster:

```bash
talosctl gen config $CLUSTER_NAME https://$CONTROL_PLANE_IP:6443 --install-disk /dev/$DISK_NAME
```

This generated the following files:
- `controlplane.yaml` - Configuration for the control plane node
- `worker.yaml` - Configuration for worker nodes
- `talosconfig` - Client configuration for talosctl

### 4. Apply Configuration

#### Control Plane Node

```bash
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file controlplane.yaml
```

#### Worker Nodes

```bash
for ip in "${WORKER_IP[@]}"; do
    echo "Applying config to worker node: $ip"
    talosctl apply-config --insecure --nodes "$ip" --file worker.yaml
done
```

### 5. Configure Talosctl Endpoints

Set the control plane IP as the endpoint for talosctl:

```bash
talosctl --talosconfig=./talosconfig config endpoints $CONTROL_PLANE_IP
```

### 6. Bootstrap the Cluster

Initialize the Kubernetes control plane:

```bash
talosctl bootstrap --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig
```

### 7. Retrieve Kubeconfig

Generate and save the kubeconfig for kubectl access:

```bash
talosctl kubeconfig --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig
```

This file is saved to `~/.kube/config`.

### 8. Verify Cluster Status

Check the cluster's health:

```bash
talosctl --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig health
```

Verify that all nodes are ready:

```bash
kubectl get nodes
```

Expected output:
```
NAME            STATUS   ROLES           AGE    VERSION
talos-46y-tj6   Ready    control-plane   102s   v1.33.1
talos-cwm-ls3   Ready    <none>          93s    v1.33.1
talos-j7g-w2m   Ready    <none>          90s    v1.33.1
```

### 9. Generate Secrets Backup

Create a backup of the cluster secrets:

```bash
talosctl gen secrets -o secrets.yaml --talosconfig=./talosconfig
```

## Important Files

- `controlplane.yaml` - Control plane node configuration
- `worker.yaml` - Worker node configuration
- `talosconfig` - Talosctl client configuration
- `secrets.yaml` - Cluster secrets (backup)
- `~/.kube/config` - Kubectl configuration

## Cluster Management

### Talosctl Commands

To use talosctl with the cluster, always use:

```bash
talosctl --talosconfig=./talosconfig --nodes $CONTROL_PLANE_IP <command>
```

### Kubectl Commands

kubectl is configured automatically through the kubeconfig file and can be used directly:

```bash
kubectl get nodes
kubectl get pods -A
```

## Networking

The cluster uses local IP addresses in the 192.168.86.0/24 network:
- Control Plane API: https://192.168.86.147:6443
- IPv6 support is enabled (e.g., fd72:dab2:dd33:44ce:be24:11ff:fe4c:6c36)
