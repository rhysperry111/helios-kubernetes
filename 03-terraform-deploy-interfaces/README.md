# Step 3 - Deploy Cluster Interfaces

Installs the core cluster infrastructure: Cilium CNI and CEPH CSI.

## What it does

- **Cilium** - deployed as the CNI with kube-proxy replacement, BGP control plane enabled, and the built-in ingress controller active. This step installs the Cilium Helm chart... the actual BGP peering configuration happens in step 4.
- **CEPH RBD/CephFS** - deployed as CSI by utilising the underlying Proxmox CEPH cluster. RBD as the default StorageClass with CephFS for RWX volumes.

## Configuration

- `kubernetes.vip` - passed to Cilium as `k8sServiceHost`.
- `ceph.*` - details required to use external CEPH cluster for CSI.

### Secrets

Create `secrets.auto.tfvars` in this directory:

```hcl
ceph_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

## Usage

```bash
make step3
# or manually:
make generate
cd 03-terraform-deploy-interfaces
terraform init -upgrade
terraform apply
```
