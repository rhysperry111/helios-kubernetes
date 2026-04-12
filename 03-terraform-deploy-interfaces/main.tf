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
      bpf = {
        masquerade = true
      }
      bgpControlPlane = {
        enabled = true
      }
    })
  ]
}

resource "helm_release" "ceph_csi_rbd" {
  name             = "ceph-rbd"
  namespace        = "ceph-rbd"
  repository       = "https://ceph.github.io/csi-charts"
  chart            = "ceph-csi-rbd"
  create_namespace = true
  wait             = false

  values = [
    yamlencode({
      csiConfig = [
        {
          clusterID = var.ceph_cluster_id
          monitors  = split(",", var.ceph_monitors)
        }
      ]

      secret = {
        create  = true
        userID  = var.ceph_user
        userKey = var.ceph_key
      }

      storageClass = {
        create = true
        name   = "ceph-rbd"

        annotations = {
          "storageclass.kubernetes.io/is-default-class" = "true"
        }

        clusterID = var.ceph_cluster_id
        pool      = var.ceph_rbd_pool

        reclaimPolicy         = "Delete"
        allowVolumeExpansion = true

        parameters = {
          imageFeatures = "layering"
        }
      }
    })
  ]
}

resource "helm_release" "ceph_csi_cephfs" {
  name       = "ceph-cephfs"
  namespace  = "ceph-cephfs"
  repository = "https://ceph.github.io/csi-charts"
  chart      = "ceph-csi-cephfs"
  create_namespace = true

  values = [
    yamlencode({
      csiConfig = [
        {
          clusterID = var.ceph_cluster_id
          monitors  = split(",", var.ceph_monitors)
        }
      ]

      secret = {
        create  = true
        userID  = var.ceph_user
        userKey = var.ceph_key
      }

      storageClass = {
        create = true
        name   = "ceph-cephfs"

        fsName = var.ceph_cephfs_name
        pool   = "kubernetes_ceph_csi_cephfs"

        reclaimPolicy         = "Delete"
        allowVolumeExpansion = true
      }
    })
  ]
}