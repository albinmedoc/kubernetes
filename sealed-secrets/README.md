# Sealed Secrets

## Description

Sealed Secrets is a Kubernetes controller and tool for one-way encrypted Secrets. It provides a secure way to store secrets in Git repositories by encrypting them with a public key. Only the controller running in the target cluster can decrypt the secrets using its private key.

The problem it solves: You want to store Kubernetes Secret manifests in Git, but secrets contain sensitive data that shouldn't be stored in plain text. Sealed Secrets allows you to encrypt your secrets into SealedSecret resources that are safe to store in version control.

## Key Features

- One-way encryption of Kubernetes Secrets
- Safe to store encrypted secrets in Git repositories
- Automatic decryption by the controller in the cluster
- Public key encryption - only the cluster can decrypt
- Supports different scoping levels (strict, namespace-wide, cluster-wide)
- GitOps-friendly workflow for secret management

## How it Works

1. Install the Sealed Secrets controller in your Kubernetes cluster
2. Use the `kubeseal` CLI tool to encrypt your secrets using the cluster's public key
3. Store the encrypted SealedSecret manifests in Git
4. Apply the SealedSecret to your cluster
5. The controller automatically decrypts it into a regular Kubernetes Secret

## Installation

Installed using the official Kubernetes manifests from the releases page: [Sealed Secrets Releases](https://github.com/bitnami-labs/sealed-secrets/releases)

The controller was deployed by applying the release manifest directly to the cluster.

## Integration with ArgoCD

Sealed Secrets works perfectly with ArgoCD for a complete GitOps workflow:

1. **Secret Management**: Create your secrets and encrypt them using `kubeseal` to generate SealedSecret manifests
2. **Git Storage**: Commit the encrypted SealedSecret YAML files to your Git repository alongside other Kubernetes manifests
3. **ArgoCD Sync**: ArgoCD monitors the Git repository and automatically syncs the SealedSecret resources to the cluster
4. **Automatic Decryption**: The Sealed Secrets controller running in the cluster automatically decrypts the SealedSecrets into regular Kubernetes Secrets
5. **Application Access**: Your applications can then use the decrypted secrets normally

This workflow ensures that:
- Secrets are never stored in plain text in Git
- The entire deployment process is declarative and version-controlled
- ArgoCD can manage secret deployments alongside application deployments
- The GitOps principle is maintained for sensitive data

## Links

- **GitHub Repository**: https://github.com/bitnami-labs/sealed-secrets
- **Documentation**: https://sealed-secrets.netlify.app/
