#!/usr/bin/env python3
import argparse
import os
import sys

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML is required.", file=sys.stderr)
    sys.exit(1)


def load_config(path: str) -> dict:
    with open(path) as f:
        return yaml.safe_load(f)


def write(path: str, content: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(content)
    print(f"  wrote {path}")


def tfvars_line(key: str, value) -> str:
    if isinstance(value, bool):
        return f'{key} = {"true" if value else "false"}'
    if isinstance(value, (int, float)):
        return f"{key} = {value}"
    if isinstance(value, list):
        items = ", ".join(f'"{v}"' for v in value)
        return f"{key} = [{items}]"
    return f'{key} = "{value}"'


def generate_step01(cfg: dict, root: str) -> None:
    net = cfg["network"]
    vms = cfg["vms"]
    px = cfg["proxmox"]
    acc = cfg["access"]

    lines = [
        "# Auto-generated from helios.yaml - do not edit manually.",
        "",
        "# Proxmox cluster",
        tfvars_line("proxmox_api_url", px["api_url"]),
        tfvars_line("proxmox_nodes", px["nodes"]),
        "",
        "# Networking",
        tfvars_line("network_prefix", net["prefix"]),
        tfvars_line("network_cidr", net["cidr"]),
        tfvars_line("gateway", net["gateway"]),
        tfvars_line("nameserver", net["nameserver"]),
        tfvars_line("searchdomain", net["searchdomain"]),
        tfvars_line("controller_ip_start", net["controller_ip_start"]),
        tfvars_line("worker_ip_start", net["worker_ip_start"]),
        tfvars_line("network_bridge", net["bridge"]),
        "",
        "# VM template and storage",
        tfvars_line("template_name", px["template_name"]),
        tfvars_line("storage_pool", px["storage_pool"]),
        "",
        "# VM sizing",
        tfvars_line("controller_count", vms["controller_count"]),
        tfvars_line("worker_count", vms["worker_count"]),
        tfvars_line("controller_vmid_base", vms["controller_vmid_base"]),
        tfvars_line("worker_vmid_base", vms["worker_vmid_base"]),
        tfvars_line("controller_cores", vms["controller"]["cores"]),
        tfvars_line("controller_memory_gb", vms["controller"]["memory_gb"]),
        tfvars_line("controller_disk_size", vms["controller"]["disk_size"]),
        tfvars_line("worker_cores", vms["worker"]["cores"]),
        tfvars_line("worker_memory_gb", vms["worker"]["memory_gb"]),
        tfvars_line("worker_disk_size", vms["worker"]["disk_size"]),
        "",
        "# Access",
        tfvars_line("ssh_public_key", acc["ssh_public_key"]),
    ]
    write(os.path.join(root, "01-terraform-proxmox-vms", "helios.auto.tfvars"), "\n".join(lines) + "\n")


def generate_step02(cfg: dict, root: str) -> None:
    k = cfg["kubernetes"]
    v = cfg["versions"]

    doc = {
        "k8s_domain": k["domain"],
        "k8s_admin_user": k["admin_user"],
        "k8s_vip": k["vip"],
        "k8s_vip_interface": k["vip_interface"],
        "k8s_pod_subnet": k["pod_subnet"],
        "k8s_service_subnet": k["service_subnet"],
        # Versions
        "k8s_version": v["kubernetes"],
        "kube_vip_version": v["kube_vip"],
        "helm_version": v["helm"],
        "k9s_version": v["k9s"],
    }
    content = "# Auto-generated from helios.yaml - do not edit manually.\n---\n"
    content += yaml.dump(doc, default_flow_style=False, sort_keys=False)
    write(os.path.join(root, "02-ansible-install-kubernetes", "group_vars", "all", "helios.auto.yaml"), content)


def generate_step03(cfg: dict, root: str) -> None:
    storage = cfg["storage"]
    k = cfg["kubernetes"]
    v = cfg["versions"]

    lines = [
        "# Auto-generated from helios.yaml - do not edit manually.",
        "",
        tfvars_line("k8s_vip", k["vip"]),
        "",
        "# Storage (CEPH)",
        tfvars_line("ceph_cluster_id", storage["cluster_id"]),
        tfvars_line("ceph_monitors", storage["monitors"]),
        tfvars_line("ceph_user", storage["user"]),
        tfvars_line("ceph_rbd_pool", storage["rbd_pool"]),
        tfvars_line("ceph_cephfs_name", storage["cephfs_name"]),
        tfvars_line("ceph_cephfs_subvolumegroup", storage["cephfs_subvolumegroup"]),
        "",
        "# Chart versions",
        tfvars_line("cilium_chart_version", v["cilium"]),
        tfvars_line("ceph_csi_rbd_chart_version", v["ceph_csi_rbd"]),
        tfvars_line("ceph_csi_cephfs_chart_version", v["ceph_csi_cephfs"]),
    ]
    write(os.path.join(root, "03-terraform-deploy-interfaces", "helios.auto.tfvars"), "\n".join(lines) + "\n")


def generate_step04(cfg: dict, root: str) -> None:
    k = cfg["kubernetes"]
    bgp = cfg["bgp"]
    unifi = cfg["unifi"]
    dns = cfg["dns"]
    tls = cfg["tls"]
    v = cfg["versions"]

    lines = [
        "# Auto-generated from helios.yaml - do not edit manually.",
        "",
        "# Kubernetes",
        tfvars_line("k8s_vip", k["vip"]),
        tfvars_line("k8s_pod_subnet", k["pod_subnet"]),
        "",
        "# BGP",
        tfvars_line("bgp_cluster_asn", bgp["cluster_asn"]),
        tfvars_line("bgp_router_asn", bgp["router_asn"]),
        tfvars_line("bgp_router_ip", bgp["router_ip"]),
        tfvars_line("bgp_lb_pool_cidr", bgp["lb_pool_cidr"]),
        tfvars_line("bgp_node_cidr", unifi["bgp_node_cidr"]),
        "",
        "# UniFi controller",
        tfvars_line("unifi_api_url", unifi["api_url"]),
        tfvars_line("unifi_allow_insecure", unifi["allow_insecure"]),
        "",
        "# DNS",
        tfvars_line("dns_provider", dns["provider"]),
        tfvars_line("dns_zone", dns["zone"]),
        "",
        "# TLS",
        tfvars_line("acme_server", tls["acme_server"]),
        tfvars_line("cluster_issuer_name", tls["cluster_issuer"]),
        "",
        "# Chart versions",
        tfvars_line("external_dns_chart_version", v["external_dns"]),
        tfvars_line("cert_manager_chart_version", v["cert_manager"]),
    ]
    write(os.path.join(root, "04-terraform-setup-networking", "helios.auto.tfvars"), "\n".join(lines) + "\n")


def generate_step05(cfg: dict, root: str) -> None:
    k = cfg["kubernetes"]
    go = cfg["gitops"]
    v = cfg["versions"]

    lines = [
        "# Auto-generated from helios.yaml - do not edit manually.",
        "",
        tfvars_line("k8s_domain", k["domain"]),
        "",
        "# ArgoCD",
        tfvars_line("argocd_namespace", go["argocd"]["namespace"]),
        tfvars_line("argocd_hostname", go["argocd"]["hostname"]),
        "",
        "# GitLab",
        tfvars_line("gitlab_namespace", go["gitlab"]["namespace"]),
        tfvars_line("gitlab_hostname", go["gitlab"]["hostname"]),
        tfvars_line("gitlab_runner_enabled", go["gitlab"]["runner_enabled"]),
        "",
        "# Chart versions",
        tfvars_line("argocd_chart_version", v["argocd"]),
        tfvars_line("gitlab_chart_version", v["gitlab"]),
    ]
    write(os.path.join(root, "05-terraform-deploy-gitops", "helios.auto.tfvars"), "\n".join(lines) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate per-step vars from helios.yaml")
    parser.add_argument("--config", default="helios.yaml", help="Path to central config (default: helios.yaml)")
    args = parser.parse_args()

    root = os.path.dirname(os.path.abspath(args.config))
    cfg = load_config(args.config)

    print("Generating per-step variable files...")
    generate_step01(cfg, root)
    generate_step02(cfg, root)
    generate_step03(cfg, root)
    generate_step04(cfg, root)
    generate_step05(cfg, root)
    print("Done.")


if __name__ == "__main__":
    main()
