# ArgoCD

## Description

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application state. ArgoCD automates the deployment of applications to target environments by monitoring Git repositories and synchronizing the live state with the desired state defined in the repository.

## Key Features

- Declarative GitOps continuous delivery
- Application deployment and lifecycle management
- Automated synchronization of desired application state
- Web UI and CLI for managing deployments
- Multi-tenancy and RBAC support
- Health status reporting and visualization

## Installation

Installed following the official guide: [ArgoCD Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd)

After installing the official Argo CD manifests, apply the repository-managed manifests in this directory:

- `argocd-ingress.yaml`
- `argocd-git-sealed-secrets.yaml`
- `repositories/kubernetes-repository.yaml`
- `projects/*.yaml`
- `argocd-servicemonitor.yaml`

Apply `argocd-servicemonitor.yaml` after the `monitoring.coreos.com` CRDs are installed by kube-prometheus-stack.

## Upgrading

1. **Check Release Notes**: Always review the [ArgoCD Release Notes](https://github.com/argoproj/argo-cd/releases) before upgrading
2. **Review Breaking Changes**: For major and minor version upgrades, carefully review the [Upgrading Guide](https://argo-cd.readthedocs.io/en/stable/operator-manual/upgrading/overview/) for breaking changes and migration steps

For detailed upgrade instructions and version-specific considerations, refer to the official [ArgoCD Upgrading Overview](https://argo-cd.readthedocs.io/en/stable/operator-manual/upgrading/overview/).

## Links

- **GitHub Repository**: https://github.com/argoproj/argo-cd
- **Documentation**: https://argo-cd.readthedocs.io/

## Metrics

Prometheus scrapes Argo CD through `argocd-servicemonitor.yaml`. The monitor lives in the `argocd` namespace and selects Argo CD's built-in metrics services.
