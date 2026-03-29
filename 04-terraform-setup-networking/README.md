# Step 4 - Setup Networking

Configures BGP peering between Cilium and the UniFi gateway, allocates LoadBalancer IP pools, and deploys ExternalDNS and cert-manager.

## What it does

### BGP (Cilium side)
- Creates a `CiliumLoadBalancerIPPool` with the configured CIDR block - services of type `LoadBalancer` get IPs from this pool.
- Creates a `CiliumBGPPeeringPolicy` so every Linux node peers with the upstream router and advertises service IPs.

### BGP (UniFi gateway side)
- Uses the [ubiquiti-community/unifi](https://registry.terraform.io/providers/ubiquiti-community/unifi/latest) Terraform provider to configure BGP on the gateway via the controller API.
- Creates a `unifi_bgp` resource in structured mode with a `CILIUM` peer group that listens on the node subnet CIDR.

### ExternalDNS
- Deploys ExternalDNS via Helm, configured for the DNS provider and zone in `helios.yaml`.
- For Cloudflare, creates a Kubernetes secret with the API token (set in `secrets.auto.tfvars`).

### cert-manager
- Deploys cert-manager via Helm with CRDs enabled.
- Creates a `ClusterIssuer` for ACME (Let's Encrypt by default) using DNS-01 challenges.

## Configuration

- `bgp.*` - ASNs, router IP, LoadBalancer pool CIDR
- `unifi.*` - controller API URL, insecure flag, BGP node listen CIDR
- `dns.*` - ExternalDNS provider and zone
- `tls.*` - ACME email, server, ClusterIssuer name

### Secrets

Create `secrets.auto.tfvars` in this directory with your UniFi credentials and DNS/TLS secrets:

```hcl
# UniFi - use EITHER api_key OR username/password
# (or set UNIFI_API_KEY / UNIFI_USERNAME / UNIFI_PASSWORD env vars)
unifi_api_key = "your-unifi-api-key"
# unifi_username = "terraform"
# unifi_password = "hunter2"

# DNS
dns_cloudflare_api_token = "your-cloudflare-api-token"

# TLS
acme_email = "you@example.com"
acme_cloudflare_api_token = "your-cloudflare-api-token"
```

It is recommended to create a dedicated Limited Admin user on the UniFi controller for Terraform rather than using your personal account.

## Usage

```bash
make step4
# or manually:
make generate
cd 04-terraform-setup-networking
terraform init -upgrade
terraform apply
```

## Verifying BGP

After applying, check that BGP sessions are established:

```bash
# On a Kubernetes node:
cilium bgp peers

# On the UniFi controller UI:
# Settings, Routing, BGP --> should show the configuration and peer status
```
