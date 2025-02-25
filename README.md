## Talos usage

## Initial setup

1. `brew install talosctl`
2. `talosctl gen config talos-proxmox-cluster https://<IP_OF_CONTROL_PLANE>:6443 --output-dir talos-proxmox-cluster`
3. `cd talos-proxmox-cluster`

3. `talosctl apply-config --insecure --nodes <IP_OF_CONTROL_PLANE> --file controlplane.yaml`
4. `talosctl apply-config --insecure --nodes <IP_OF_WORKER_NODE> --file worker.yaml`

5. `export TALOSCONFIG="talosconfig"`
6. `talosctl config endpoint <IP_OF_CONTROL_PLANE>`
7. `talosctl config node <IP_OF_CONTROL_PLANE>`

8. `talosctl bootstrap`

9. `talosctl kubeconfig .`

## Adding new worker

1. `talosctl apply-config --insecure --nodes <IP_OF_WORKER_NODE> --file worker.yaml`

## set kubeconfig
`export KUBECONFIG=kubeconfig`