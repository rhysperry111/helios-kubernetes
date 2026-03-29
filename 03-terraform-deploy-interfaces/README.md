# Step 3 - Deploy Cluster Interfaces

Installs the core cluster infrastructure: Cilium CNI and Longhorn CSI.

## What it does

- **Cilium** - deployed as the CNI with kube-proxy replacement, BGP control plane enabled, and the built-in ingress controller active. This step installs the Cilium Helm chart... the actual BGP peering configuration happens in step 4.
- **Longhorn** - deployed as the default CSI for persistent storage across worker nodes.

## Configuration

Key setting: `kubernetes.vip` - passed to Cilium as `k8sServiceHost`.

## Usage

```bash
make step3
# or manually:
make generate
cd 03-terraform-deploy-interfaces
terraform init -upgrade
terraform apply
```