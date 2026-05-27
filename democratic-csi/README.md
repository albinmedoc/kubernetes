# Democratic CSI - TrueNAS iSCSI Storage

This directory contains the Argo CD Helm wrapper for democratic-csi, which provides iSCSI-based persistent storage from TrueNAS for the Kubernetes cluster.

## Overview

- **Storage Provider**: TrueNAS (192.168.86.109)
- **Protocol**: iSCSI
  - **ZFS Parent Dataset**: `Datapool1/Kubernetes/iscsi/volumes`
  - **Snapshots Dataset**: `Datapool1/Kubernetes/iscsi/snapshots`
- **Storage Class**: `truenas-iscsi`

## Prerequisites

### Talos Configuration
All nodes must have the `iscsi-tools` system extension installed:
- Verify with: `talosctl get extensions`
- Check service: `talosctl get services | grep ext-iscsid`

### TrueNAS Configuration
1. ZFS datasets created at:
   - `Datapool1/Kubernetes/iscsi/volumes`
   - `Datapool1/Kubernetes/iscsi/snapshots`

2. API key configured for root user
3. iSCSI service enabled

### Snapshot Support Prerequisites

Before installing democratic-csi, install the Kubernetes snapshot CRDs and controller:

```bash
# Install the snapshot CRDs
kubectl kustomize https://github.com/kubernetes-csi/external-snapshotter/client/config/crd | kubectl create -f -

# Install the snapshot controller
kubectl kustomize https://github.com/kubernetes-csi/external-snapshotter/deploy/kubernetes/snapshot-controller | kubectl create -f -
```

### Installation with Argo CD

Argo CD deploys democratic-csi from the local Helm wrapper in this directory. The wrapper depends on the upstream `democratic-csi/democratic-csi` Helm chart and uses the `truenas-iscsi` release name, matching the previous manual Helm install.

The Argo CD Application creates the `democratic-csi` namespace with `CreateNamespace=true` and manages the privileged pod security labels with `managedNamespaceMetadata`.

Only the TrueNAS API key is stored as a Secret. The non-secret democratic-csi driver config lives in `values.yaml`, with `apiKey: $TRUENAS_API_KEY`. The Helm chart injects `TRUENAS_API_KEY` from the Secret into the controller and node driver containers.

democratic-csi expands environment variables in the driver config at runtime, so `apiKey: $TRUENAS_API_KEY` is resolved inside the driver pod.

The expected Secret is:

```text
democratic-csi-secrets
```

Use `democratic-csi-secrets.yaml.example` as the plaintext template and commit the generated SealedSecret under `democratic-csi/templates/`. See [sealed-secrets/README.md](../sealed-secrets/README.md) for the shared sealing workflow.

## Verification

```bash
# Check pods
kubectl get pods -n democratic-csi

# Verify storage class
kubectl get storageclass truenas-iscsi
```

### Usage

Use `truenas-iscsi` for databases and high I/O applications. It supports `ReadWriteOnce`.

## Upgrade

Update `Chart.yaml` to the desired upstream chart version, then let Argo CD sync the Application.

## Uninstall

Remove `argocd/applications/democratic-csi.yaml` from the app-of-apps source and let Argo CD prune the Application.
