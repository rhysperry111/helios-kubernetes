terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

provider "kubernetes" {
  config_path = "./kubeconfig.autogen.yaml"
}

provider "helm" {
  kubernetes = {
    config_path = "./kubeconfig.autogen.yaml"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  wait       = true

  values = [
    yamlencode({
      global = {
        domain = var.argocd_hostname
      }
      server = {
        ingress = {
          enabled          = true
          ingressClassName = "cilium"
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
          }
          hostname = var.argocd_hostname
          tls      = true
        }
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]
}

resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = var.gitlab_namespace
  }
}

resource "helm_release" "gitlab" {
  name       = "gitlab"
  namespace  = kubernetes_namespace.gitlab.metadata[0].name
  repository = "https://charts.gitlab.io/"
  chart      = "gitlab"
  timeout    = 900
  wait       = false

  values = [
    yamlencode({
      installCertmanager = false
      "nginx-ingress" = { enabled = false }

      global = {
        hosts = {
          domain   = var.k8s_domain
          https    = true
          gitlab   = { name = var.gitlab_hostname }
          externalIP = null
        }
        ingress = {
          class = "cilium"
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
          }
          configureCertmanager = false
        }
      }

      prometheus = { install = false }

      "gitlab-runner" = {
        install = var.gitlab_runner_enabled
      }

      gitlab = {
        webservice = {
          ingress = {
            tls = {
              secretName = "helios-gitlab-web-tls"
            }
          }
        }
        kas = {
          ingress = {
            tls = {
              secretName = "helios-gitlab-kas-tls"
            }
          }
        }
      }
      registry = {
        enabled = false
        ingress = {
          tls = {
            secretName = "helios-gitlab-registry-tls"
          }
        }
      }
      minio = {
        ingress = {
          tls = {
            secretName = "helios-gitlab-minio-tls"
          }
        }
      }
    })
  ]
}
