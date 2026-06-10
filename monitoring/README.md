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

## Upgrading

Update the dependency version in `Chart.yaml`, review the upstream kube-prometheus-stack upgrade notes, then let Argo CD sync the Application.

Pay special attention to Prometheus Operator CRD changes during upgrades.
