# Democratic CSI - TrueNAS iSCSI Storage

This directory contains configuration for democratic-csi, which provides iSCSI-based persistent storage from TrueNAS for the Kubernetes cluster.

## Overview

- **Storage Provider**: TrueNAS (192.168.86.109)
- **Protocol**: iSCSI
- **ZFS Parent Dataset**: `Datapool1/k8s/iscsi/vols`
- **Snapshots Dataset**: `Datapool1/k8s/iscsi/snaps`
- **Storage Class**: `truenas-iscsi`

## Prerequisites

### Talos Configuration
All nodes must have the `iscsi-tools` system extension installed:
- Verify with: `talosctl get extensions`
- Check service: `talosctl get services | grep ext-iscsid`

### TrueNAS Configuration
1. ZFS datasets created at:
   - `Datapool1/k8s/iscsi/vols`
   - `Datapool1/k8s/iscsi/snaps`

2. API key configured for root user
3. iSCSI service enabled

### Installation Democratic CSI
```bash
# Add helm repository
helm repo add democratic-csi https://democratic-csi.github.io/charts/
helm repo update `democratic-csi-values.yaml`

## Update with correct API-KEY
nano democratic-csi-values.yaml

## Create namespace
kubectl apply -f democratic-csi-namespace.yaml

# Install with values file
helm install truenas-iscsi democratic-csi/democratic-csi \
  --namespace democratic-csi \
  -f democratic-csi-values.yaml
```

## Verification

```bash
# Check pods
kubectl get pods -n democratic-csi

# Verify storage class
kubectl get storageclass truenas-iscsi
```

## Upgrade

```bash
helm repo update
helm upgrade truenas-iscsi democratic-csi/democratic-csi \
  --namespace democratic-csi \
  -f truenas-iscsi-values.yaml
```

## Uninstall

```bash
helm uninstall truenas-iscsi -n democratic-csi
kubectl delete namespace democratic-csi
```