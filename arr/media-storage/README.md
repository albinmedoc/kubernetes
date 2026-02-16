# Media Storage - SMB CSI Driver

This directory contains configuration for mounting TrueNAS SMB shares as persistent volumes in Kubernetes using the SMB CSI driver.

## Prerequisites

The SMB CSI driver must be installed in the cluster before these resources can be used.

## Installation

### 1. Install SMB CSI Driver

```bash
# Install using the official install script
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/v1.20.0/deploy/install-driver.sh | bash -s v1.20.0 --
```

### 2. Verify Installation

```bash
# Check CSI driver pods are running
kubectl get pods -n kube-system | grep csi-smb

# Verify CSI driver is registered
kubectl get csidrivers | grep smb
```

Expected output:
```
csi-smb-controller-xxx   2/2     Running
csi-smb-node-xxx         3/3     Running
smb.csi.k8s.io           1         true
```

### 3. Create Secrets

Copy the example secrets file and fill in your TrueNAS SMB credentials:

```bash
cp media-storage-secrets.yaml.example media-storage-secrets.yaml
# Edit the file with your credentials
kubectl apply -f media-storage-secrets.yaml
```

### 4. Apply Storage Resources

```bash
# Apply in order:
kubectl apply -f media-storage-pv.yaml
kubectl apply -f media-storage-pvc.yaml
```

### 5. Verify Storage

```bash
kubectl get pv media-storage-pv
kubectl get pvc media-storage-pvc -n arr
```

## Usage

Applications can mount this shared media storage by referencing the PVC:

```yaml
volumes:
  - name: media
    persistentVolumeClaim:
      claimName: media-storage-pvc
```

## Documentation

Official SMB CSI Driver documentation:
- Installation Guide: https://github.com/kubernetes-csi/csi-driver-smb/blob/master/docs/install-smb-csi-driver.md
- GitHub Repository: https://github.com/kubernetes-csi/csi-driver-smb

## Notes

- The SMB share is mounted with `dir_mode=0777,file_mode=0777` for compatibility with multiple applications
- All *arr applications (Sonarr, Radarr, SABnzbd, etc.) share this same media volume
- The PV is set to `persistentVolumeReclaimPolicy: Retain` to prevent accidental data loss
