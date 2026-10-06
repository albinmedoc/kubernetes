# Tailscale Kubernetes Operator

This Argo CD Helm wrapper installs the official Tailscale Kubernetes operator chart in the `tailscale` namespace. The chart version is pinned in `Chart.yaml`.

## OAuth credentials

Before syncing the Argo CD application, configure the tailnet policy and create OAuth credentials for the operator. Follow [Tailscale's installation guide](https://tailscale.com/docs/kubernetes-operator/install-operator).

Add `tag:k8s-operator` and `tag:k8s` to the tailnet policy. Allow `tag:k8s-operator` to own `tag:k8s`, for example:

```json
{
  "tagOwners": {
    "tag:k8s-operator": ["autogroup:admin"],
    "tag:k8s": ["tag:k8s-operator"]
  }
}
```

Create an OAuth client with write access to `General/Services`, `Devices/Core`, and `Keys/Auth Keys`, scoped to `tag:k8s-operator`.

The operator reads credentials from the `tailscale-secrets` Secret using the keys `client_id` and `client_secret`. Copy the example, replace both placeholders, and seal the Secret:

```bash
cp tailscale/templates/tailscale-secrets.yaml.example tailscale/templates/tailscale-secrets.yaml
# Edit the copied file and replace both placeholder values.
kubeseal -f tailscale/templates/tailscale-secrets.yaml \
  -w tailscale/templates/tailscale-sealed-secrets.yaml -o yaml
```

Commit the generated SealedSecret, not the plaintext Secret. The plaintext filename is excluded by both `.gitignore` and `.helmignore`; `.helmignore` also excludes the example file. Argo CD installs the chart into the `tailscale` namespace.
