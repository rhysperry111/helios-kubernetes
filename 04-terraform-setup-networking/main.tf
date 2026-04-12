terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kubectl = {
      source = "alekc/kubectl"
    }
    helm = {
      source = "hashicorp/helm"
    }
    unifi = {
      source  = "ubiquiti-community/unifi"
    }
  }
}

provider "kubernetes" {
  config_path = "./kubeconfig.autogen.yaml"
}

provider "kubectl" {
  config_path = "./kubeconfig.autogen.yaml"
}

provider "helm" {
  kubernetes = {
    config_path = "./kubeconfig.autogen.yaml"
  }
}

provider "unifi" {
  api_url        = var.unifi_api_url
  allow_insecure = var.unifi_allow_insecure

  api_key  = var.unifi_api_key != "" ? var.unifi_api_key : null
  username = var.unifi_api_key == "" ? var.unifi_username : null
  password = var.unifi_api_key == "" ? var.unifi_password : null
}

resource "kubectl_manifest" "cilium_lb_ip_pool" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "default-pool"
    }
    spec = {
      blocks = [
        { cidr = var.bgp_lb_pool_cidr }
      ]
    }
  })
}

resource "kubectl_manifest" "cilium_bgp_peer_config" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumBGPPeerConfig"
    metadata = {
      name = "default-peer"
    }
    spec = {
      families = [
        {
          afi  = "ipv4"
          safi = "unicast"
          advertisements = {
            matchLabels = {
              "advertise" = "bgp"
            }
          }
        }
      ]
    }
  })
}

resource "kubectl_manifest" "cilium_bgp_advertisement" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumBGPAdvertisement"
    metadata = {
      name = "bgp-advertisements"
      labels = {
        "advertise" = "bgp"
      }
    }
    spec = {
      advertisements = [
        {
          advertisementType = "Service"
          service = {
            addresses = ["LoadBalancerIP"]
          }
          selector = {
            matchExpressions = [
              {
                key      = "somekey"
                operator = "NotIn"
                values   = ["never-match-this"]
              }
            ]
          }
        }
      ]
    }
  })
}

resource "kubectl_manifest" "cilium_bgp_cluster_config" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumBGPClusterConfig"
    metadata = {
      name = "default-bgp"
    }
    spec = {
      nodeSelector = {
        matchLabels = {
          "kubernetes.io/os" = "linux"
        }
      }
      bgpInstances = [
        {
          name     = "default"
          localASN = var.bgp_cluster_asn
          peers = [
            {
              name          = "router"
              peerASN       = var.bgp_router_asn
              peerAddress   = var.bgp_router_ip
              peerConfigRef = {
                name = "default-peer"
              }
            }
          ]
        }
      ]
    }
  })
}

resource "unifi_bgp" "kubernetes" {
  description = "Kubernetes Cilium BGP peering"
  enabled     = true

  asn       = var.bgp_router_asn
  router_id = var.bgp_router_ip

  peers = [
    {
      name        = "CILIUM"
      remote_as   = var.bgp_cluster_asn
      description = "Cilium BGP peer group"
      networks    = [var.bgp_node_cidr]
    }
  ]
}
resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "external_dns_credentials" {

  metadata {
    name      = "external-dns-credentials"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
  }

  data = {
    dns_cloudflare_api_token = var.dns_cloudflare_api_token
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.external_dns_chart_version
  wait       = true

  values = [
    yamlencode({
      provider = {
        name = var.dns_provider
      }
      domainFilters = [var.dns_zone]
      policy        = "sync"
      sources       = ["ingress"]
      env = [
        {
          name = "CF_API_TOKEN"
          valueFrom = {
            secretKeyRef = {
              name = "external-dns-credentials"
              key  = "dns_cloudflare_api_token"
            }
          }
        }
      ]
    })
  ]

  depends_on = [kubernetes_secret.external_dns_credentials]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_chart_version
  wait       = true

  values = [
    yamlencode({
      crds = {
        enabled = true 
      }
      extraArgs = [
        "--dns01-recursive-nameservers-only",
        "--dns01-recursive-nameservers=https://1.1.1.1/dns-query,https://8.8.8.8/dns-query",
        "--dns01-check-retry-period=2s"
      ]
    })
  ]
}

resource "kubernetes_secret" "cert_manager_cloudflare" {
  metadata {
    name      = "acme-cloudflare-api-token"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }

  data = {
    acme-api-token = var.acme_cloudflare_api_token
  }
}

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.cluster_issuer_name
    }
    spec = {
      acme = {
        email  = var.acme_email
        server = var.acme_server
        privateKeySecretRef = {
          name = "${var.cluster_issuer_name}-account-key"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = "acme-cloudflare-api-token"
                  key  = "acme-api-token"
                }
              }
            }
          }
        ]
      }
    }
  })

  depends_on = [helm_release.cert_manager, kubernetes_secret.cert_manager_cloudflare]
}
