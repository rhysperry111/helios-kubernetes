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
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  create_namespace = true

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
      k8sServiceHost = "192.168.0.220"
      k8sServicePort = 6443
    })
  ]
}

resource "helm_release" "longhorn" {
  depends_on = [helm_release.cilium]
  name       = "longhorn"
  namespace  = "longhorn-system"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  create_namespace = true
  values     = []
}
