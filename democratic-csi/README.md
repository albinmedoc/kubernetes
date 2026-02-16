# Democratic CSI - TrueNAS NFS & iSCSI Storage

This directory contains configuration for democratic-csi, which provides NFS & iSCSI-based persistent storage from TrueNAS for the Kubernetes cluster.

## Overview

- **Storage Provider**: TrueNAS (192.168.86.109)
- **Protocol**: NFS
  - **ZFS Parent Dataset**: `Datapool1/k8s/nfs/vols`
- **Protocol**: iSCSI
  - **ZFS Parent Dataset**: `Datapool1/k8s/iscsi/vols`
  - **Snapshots Dataset**: `Datapool1/k8s/iscsi/snaps`
- **Storage Class**: `truenas-iscsi` & `truenas-nfs`

## Prerequisites

### Talos Configuration
All nodes must have the `iscsi-tools` system extension installed:
- Verify with: `talosctl get extensions`
- Check service: `talosctl get services | grep ext-iscsid`

### TrueNAS Configuration
1. ZFS datasets created at:
   - `Datapool1/k8s/nfs/vols`
   - `Datapool1/k8s/iscsi/vols`
   - `Datapool1/k8s/iscsi/snaps`

2. API key configured for root user
3. NFS & iSCSI service enabled

### Snapshot Support Prerequisites

Before installing democratic-csi, install the Kubernetes snapshot CRDs and controller:

```bash
# Install the snapshot CRDs
kubectl kustomize https://github.com/kubernetes-csi/external-snapshotter/client/config/crd | kubectl create -f -

# Install the snapshot controller
kubectl kustomize https://github.com/kubernetes-csi/external-snapshotter/deploy/kubernetes/snapshot-controller | kubectl create -f -
```

### Installation Democratic CSI
```bash
# Add helm repository
helm repo add democratic-csi https://democratic-csi.github.io/charts/
helm repo update

## Create namespace
kubectl apply -f democratic-csi-namespace.yaml

# NFS installation
nano nfs-values.yaml ## Update with correct API-KEY
helm install truenas-nfs democratic-csi/democratic-csi \
  --namespace democratic-csi \
  -f nfs-values.yaml

# iSCSI installation
nano iscsi-values.yaml ## Update with correct API-KEY
helm install truenas-iscsi democratic-csi/democratic-csi \
  --namespace democratic-csi \
  -f iscsi-values.yaml
```

## Verification

```bash
# Check pods
kubectl get pods -n democratic-csi

# Verify storage class
kubectl get storageclass truenas-iscsi
```

### Usage

Choose the appropriate storage class based on your needs:

- truenas-nfs: Use for shared storage and applications needing easy file access (supports ReadWriteMany)
- truenas-iscsi: Use for databases and high I/O applications (ReadWriteOnce only)

## Upgrade

```bash
helm repo update
helm upgrade truenas-nfs democratic-csi/democratic-csi \
  --namespace democratic-csi \
  -f nfs-values.yaml
helm upgrade truenas-iscsi democratic-csi/democratic-csi \
  --namespace democratic-csi \
  -f iscsi-values.yaml
```

## Uninstall

```bash
helm uninstall truenas-nfs -n democratic-csi
helm uninstall truenas-iscsi -n democratic-csi
kubectl delete namespace democratic-csi
```