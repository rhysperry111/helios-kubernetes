# Step 1 - Provision Proxmox VMs

Creates controller and worker VMs on Proxmox by cloning a cloud-init template. VMs are distributed across the configured Proxmox nodes sequentially.

## What it does

- Creates a `kubernetes` resource pool in Proxmox.
- Clones `controller_count` controller VMs and `worker_count` worker VMs from the cloud-init template.
- Assigns static IPs, SSH keys, and DNS settings via cloud-init.
- Generates an Ansible inventory at `../02-ansible-install-kubernetes/inventory.autogen.yaml`.

## Configuration

- `proxmox.*` - API URL, node list, template, storage pool
- `vms.*` - counts, VMID bases, CPU/RAM/disk sizing
- `network.*` - IP prefix, gateway, bridge, per-role IP start offsets
- `access.ssh_public_key` - injected into every VM

### Secrets

Create `secrets.auto.tfvars` in this directory:

```hcl
proxmox_token_id     = "user@pve!terraform"
proxmox_token_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

## Usage

```bash
make step1
# or manually:
make generate
cd 01-terraform-proxmox-vms
terraform init -upgrade
terraform apply
```