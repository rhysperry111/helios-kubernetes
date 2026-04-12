#
# Kubernetes
#

variable "k8s_vip" {
  description = "Kubernetes API VIP (used by kubeconfig)"
  type        = string
}

variable "k8s_pod_subnet" {
  description = "Pod CIDR (for reference in BGP export policies)"
  type        = string
}

#
# BGP
#

variable "bgp_cluster_asn" {
  description = "BGP autonomous system number for the Kubernetes cluster"
  type        = number
}

variable "bgp_router_asn" {
  description = "BGP autonomous system number for the upstream router"
  type        = number
}

variable "bgp_router_ip" {
  description = "IP address of the upstream BGP peer (UniFi gateway)"
  type        = string
}

variable "bgp_lb_pool_cidr" {
  description = "CIDR block allocated to LoadBalancer services"
  type        = string
}

#
# UniFi Controller
#

variable "unifi_api_url" {
  description = "UniFi Controller API URL (no /api suffix)"
  type        = string
}

variable "unifi_allow_insecure" {
  description = "Skip TLS verification for the UniFi controller"
  type        = bool
  default     = true
}

variable "unifi_api_key" {
  description = "UniFi API key (preferred over username/password). Set in secrets.auto.tfvars or UNIFI_API_KEY env var."
  type        = string
  default     = ""
  sensitive   = true
}

variable "unifi_username" {
  description = "UniFi controller username. Set in secrets.auto.tfvars or UNIFI_USERNAME env var."
  type        = string
  default     = ""
  sensitive   = true
}

variable "unifi_password" {
  description = "UniFi controller password. Set in secrets.auto.tfvars or UNIFI_PASSWORD env var."
  type        = string
  default     = ""
  sensitive   = true
}

variable "bgp_node_cidr" {
  description = "CIDR range covering all Kubernetes node IPs (used as BGP listen range on the gateway)"
  type        = string
}

#
# ExternalDNS
#

variable "dns_provider" {
  description = "ExternalDNS provider name (cloudflare, pihole, rfc2136...)"
  type        = string
  default     = "cloudflare"
}

variable "dns_zone" {
  description = "DNS zone ExternalDNS manages"
  type        = string
}

variable "dns_cloudflare_api_token" {
  description = "Cloudflare API token for ExternalDNS (set in secrets.auto.tfvars)"
  type        = string
  default     = ""
  sensitive   = true
}

#
# cert-manager
#

variable "acme_email" {
  description = "E-mail address for ACME certificate registration"
  type        = string
}

variable "acme_server" {
  description = "ACME directory URL"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "acme_cloudflare_api_token" {
  description = "Cloudflare API token for cert-manager DNS-01 challenges (set in secrets.auto.tfvars)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cluster_issuer_name" {
  description = "Name of the ClusterIssuer resource"
  type        = string
  default     = "letsencrypt-prod"
}

#
# Chart versions
#

variable "external_dns_chart_version" {
  description = "ExternalDNS Helm chart version"
  type        = string
}

variable "cert_manager_chart_version" {
  description = "cert-manager Helm chart version"
  type        = string
}
