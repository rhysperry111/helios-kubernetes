# Step 2 - Install Kubernetes

Configures all VMs and bootstraps a multi-controller Kubernetes cluster using `kubeadm`.

## What it does

1. **Common setup** - disables swap, loads kernel modules, configures sysctl, sets hostnames, installs packages (`containerd`, `kubeadm`, `kubelet`), and enables services.
2. **kube-vip** - deploys a static pod on each controller for HA API access via a floating VIP.
3. **Bootstrap** - runs `kubeadm init` on the primary controller (with kube-proxy disabled for Cilium).
4. **Join** - secondary controllers join the control plane one at a time; workers join in parallel.
5. **Admin tooling** - installs `kubectl`, `helm`, `k9s` on controllers and copies `admin.conf` to the user's home.
6. **Export** - fetches `kubeconfig.autogen.yaml` to steps 3, 4, and 5.

## Configuration

- `kubernetes.domain` - FQDN suffix for nodes
- `kubernetes.vip` / `vip_interface` - kube-vip floating IP
- `kubernetes.pod_subnet` / `service_subnet` - CIDR ranges

## Usage

```bash
make step2
# or manually:
cd 02-ansible-install-kubernetes
ansible-playbook kubernetecize.yaml
```