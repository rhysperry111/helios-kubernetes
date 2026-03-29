# Step 5 - Deploy GitOps

Deploys ArgoCD and GitLab into the cluster for a complete GitOps workflow.

## What it does

### ArgoCD
- Creates the `argocd` namespace and deploys the Argo CD Helm chart.
- Configures an Ingress with TLS (via the cert-manager ClusterIssuer from step 4) on the hostname defined in `helios.yaml`.
- Runs in insecure mode behind the ingress (TLS terminates at the Cilium ingress controller).

### GitLab
- Creates the `gitlab` namespace and deploys the GitLab Helm chart.
- Disables the bundled NGINX ingress and cert-manager (we use our own from step 4).
- Disables the container registry and Prometheus to save resources in a homelab context.
- Optionally deploys GitLab Runner for in-cluster CI/CD.

## Configuration

- `gitops.argocd.*` - namespace and hostname
- `gitops.gitlab.*` - namespace, hostname, runner toggle
- `kubernetes.domain` - base domain passed to GitLab's global host config

## Usage

```bash
make step5
# or manually:
make generate
cd 05-terraform-deploy-gitops
terraform init -upgrade
terraform apply
```

## Post-deploy

**ArgoCD initial admin password:**

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**GitLab initial root password:**

```bash
kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d
```