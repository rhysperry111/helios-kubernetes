terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = "./kubeconfig.autogen.yaml"
  }
}

resource "helm_release" "cilium" {
  name             = "cilium"
  namespace        = "kube-system"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  create_namespace = true
  wait             = false

  values = [
    yamlencode({
      ipam = {
        mode = "kubernetes"
      }
      kubeProxyReplacement = true
      externalIPs = {
        enabled = true
      }
      ingressController = {
        enabled = true
      }
      k8sServiceHost       = var.k8s_vip
      k8sServicePort       = 6443
    })
  ]
}

resource "helm_release" "longhorn" {
  name             = "longhorn"
  namespace        = "longhorn-system"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  create_namespace = true
  wait             = false
}
