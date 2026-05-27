# Velero

This directory contains the Argo CD Helm wrapper for Velero.

Velero is configured for:

- daily Kubernetes resource backups to Backblaze B2
- weekly and monthly offsite PVC data backups to Backblaze B2
- restore testing

Local PVC protection remains handled by TrueNAS recursive periodic ZFS snapshots. There is intentionally no Velero schedule for TrueNAS-local snapshot backups.

## Secrets

Create a plaintext secret manifest from `templates/velero-secrets.yaml.example`, fill in the Backblaze B2 key ID, application key, and Kopia repository password, then seal it:

```bash
kubeseal -f velero/templates/velero-secrets.yaml \
  -w velero/templates/velero-sealed-secrets.yaml \
  -o yaml
```

The `velero-repo-credentials` secret must exist before the first PVC data backup creates a Kopia repository. Changing `repository-password` after the first data backup will make older PVC backups unreadable.

## CSI Data Movement

The `truenas-iscsi` `VolumeSnapshotClass` is labeled for Velero CSI use. Weekly and monthly PVC schedules set `snapshotMoveData: true`, so Velero creates temporary democratic-csi snapshots and moves PVC data into Backblaze B2.

The daily `resources-daily` schedule sets `snapshotVolumes: false` and `snapshotMoveData: false`, so it backs up Kubernetes resources only.

## Verification

After Argo CD syncs Velero, verify:

```bash
kubectl get pods -n velero
velero backup-location get
velero schedule get
```

Trigger a resource-only test:

```bash
velero backup create manual-resources-test \
  --from-schedule velero-resources-daily
```

Trigger a PVC data movement test:

```bash
velero backup create manual-pvc-test \
  --from-schedule velero-offsite-pvc-weekly

kubectl -n velero get datauploads
velero backup describe manual-pvc-test --details
```

Restore-test into a temporary namespace before relying on the backup:

```bash
velero restore create restore-test \
  --from-backup manual-pvc-test \
  --namespace-mappings <source-namespace>:restore-test
```

Confirm the restored pod starts and the restored PVC contains expected data, then remove the temporary namespace and restore object.
