# HELIOS Kubernetes on Proxmox - IaC

> Infrastructure-as-Code for my Kubernetes homelab on Proxmox.

## Components

- Step 1 - Terraform - Provision VMs on Proxmox
- Step 2 - Ansible - Install Kubernetes (kubeadm)
- Step 3 - Terraform - Cilium CNI + CEPH CSI
- Step 4 - Terraform - BGP, ExternalDNS, cert-manager
- Step 5 - Terraform - ArgoCD + GitLab

All steps are configured from `helios.yaml` at the repo root. A Python script generates the per-step variable files from this, including pinned versions for all external dependencies.

## Dependencies

| Tool | Purpose |
|------|---------|
| Terraform | Steps 1, 3, 4, 5 |
| Ansible | Step 2 |
| Python 3 + PyYAML | Config generation |
| GNU Make | Orchestration |

You also need a Proxmox cloud-init template based on Fedora Cloud to clone VMs from, a Unifi gateway capable of BGP peering, and DNS hosted in Cloudflare.

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/rhysperry111/helios-kubernetes.git
cd helios-kubernetes

# 2. Edit the central config
nano helios.yaml # Adjust as needed for how you need infrastructure deployed

# 3. Add secrets (.gitignore'ed by default)
cat > 01-terraform-proxmox-vms/secrets.auto.tfvars <<EOF
proxmox_token_id     = "user@pve!terraform"
proxmox_token_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
EOF

cat > 03-terraform-deploy-interfaces/secrets.auto.tfvars <<EOF
ceph_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
EOF

cat > 04-terraform-setup-networking/secrets.auto.tfvars <<EOF
unifi_api_key             = "your-unifi-api-key"
dns_cloudflare_api_token  = "your-cloudflare-api-token"
acme_email                = "you@example.com"
acme_cloudflare_api_token = "your-cloudflare-api-token"
EOF

# 4. Generate step configs and run all
make all
```

## Configuration

Every tuneable value is exposed in `helios.yaml`. Running `make generate` will generate these, but this is also automatically done by other make commands where needed.

Secrets should go in `secrets.auto.tfvars` files for each step.

## Versioning

All external dependencies are pinned in `helios.yaml` under the `versions:` key. To upgrade a component, bump the version there and re-run the relevant step. The generator propagates versions to Ansible group_vars (step 2) and Terraform tfvars (steps 3–5).

## Build

```bash
make all   # Runs steps 1 -> 2 -> 3 -> 4 -> 5
make step3 # Runs step 3
```

## Teardown

```bash
make destroy-all   # Destroys 5 -> 4 -> 3 -> 1
make destroy-step4 # Destroy step 4
```

## Step Details

| Step | Directory | README |
|------|-----------|--------|
| 1. Proxmox VMs | [`01-terraform-proxmox-vms/`](01-terraform-proxmox-vms/) | [README](01-terraform-proxmox-vms/README.md) |
| 2. Kubernetes install | [`02-ansible-install-kubernetes/`](02-ansible-install-kubernetes/) | [README](02-ansible-install-kubernetes/README.md) |
| 3. Cluster interfaces | [`03-terraform-deploy-interfaces/`](03-terraform-deploy-interfaces/) | [README](03-terraform-deploy-interfaces/README.md) |
| 4. Networking | [`04-terraform-setup-networking/`](04-terraform-setup-networking/) | [README](04-terraform-setup-networking/README.md) |
| 5. GitOps | [`05-terraform-deploy-gitops/`](05-terraform-deploy-gitops/) | [README](05-terraform-deploy-gitops/README.md) |

## License

[MIT](LICENSE)
