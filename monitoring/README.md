# Monitoring

This directory contains the Argo CD Helm wrapper for `kube-prometheus-stack`.

## Grafana OIDC

Grafana is exposed at `https://grafana.albinmedoc.se` and uses Authentik through Grafana's native Generic OAuth support.

Create an Authentik OAuth2/OpenID provider with this redirect URI:

```text
https://grafana.albinmedoc.se/login/generic_oauth
```

The non-secret Grafana OIDC settings live in `templates/grafana-configmap.yaml`. Use `templates/grafana-secrets.yaml.example` as the plaintext template for Grafana admin credentials and OAuth credentials, then commit only the generated SealedSecret under `monitoring/templates/`. The chart `.helmignore` excludes example and plaintext secret files from Helm rendering.

The sealed secret must contain these keys:

- `GF_SECURITY_ADMIN_USER`
- `GF_SECURITY_ADMIN_PASSWORD`
- `GF_AUTH_GENERIC_OAUTH_CLIENT_ID`
- `GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET`

```bash
cp monitoring/templates/grafana-secrets.yaml.example monitoring/templates/grafana-secrets.yaml
kubeseal -f monitoring/templates/grafana-secrets.yaml -w monitoring/templates/grafana-sealed-secrets.yaml -o yaml
```

The Grafana role mapping expects this Authentik group name:

- `Grafana Admin` -> `GrafanaAdmin`
- all other authenticated users -> `Viewer`

## Plex Exporter

The Plex Media Server exporter scrapes the Plex server at `http://192.168.86.122:32400` and exposes Prometheus metrics on port `9594`.

Create and seal the Plex token secret before syncing the exporter:

```bash
cp monitoring/templates/exporters/plex-media-server-exporter/plex-media-server-exporter-secrets.yaml.example \
  monitoring/templates/exporters/plex-media-server-exporter/plex-media-server-exporter-secrets.yaml
kubeseal -f monitoring/templates/exporters/plex-media-server-exporter/plex-media-server-exporter-secrets.yaml \
  -w monitoring/templates/exporters/plex-media-server-exporter/plex-media-server-exporter-sealed-secrets.yaml \
  -o yaml
```

## Upgrading

Update the dependency version in `Chart.yaml`, review the upstream kube-prometheus-stack upgrade notes, then let Argo CD sync the Application.

Pay special attention to Prometheus Operator CRD changes during upgrades.
