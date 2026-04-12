variable "k8s_domain" {
  description = "Base domain for the Kubernetes cluster"
  type        = string
}

#
# ArgoCD
#

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_hostname" {
  description = "Hostname for the ArgoCD web UI"
  type        = string
}

#
# GitLab
#

variable "gitlab_namespace" {
  description = "Kubernetes namespace for GitLab"
  type        = string
  default     = "gitlab"
}

variable "gitlab_hostname" {
  description = "Hostname for the GitLab web UI"
  type        = string
}

variable "gitlab_runner_enabled" {
  description = "Deploy GitLab Runner alongside GitLab"
  type        = bool
  default     = true
}

#
# Chart versions
#

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
}

variable "gitlab_chart_version" {
  description = "GitLab Helm chart version"
  type        = string
}
