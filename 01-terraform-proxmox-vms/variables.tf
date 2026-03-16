#
# Provider credentials
#

variable "proxmox_api_url" {
  description = "Full URL to the Proxmox API endpoint"
  type        = string
}

variable "proxmox_token_id" {
  description = "Proxmox API token ID (e.g. user@pve!token-name)"
  type        = string
}

variable "proxmox_token_secret" {
  description = "Proxmox API token secret UUID"
  type        = string
  sensitive   = true
}

#
# Cluster topology
#

variable "proxmox_nodes" {
  description = "List of Proxmox nodes. VMs are distributed across them."
  type        = list(string)
}

variable "controller_count" {
  description = "Number of Kubernetes controller VMs to create"
  type        = number
  default     = 3
}

variable "worker_count" {
  description = "Number of Kubernetes worker VMs to create"
  type        = number
  default     = 3
}

variable "controller_vmid_base" {
  description = "Starting VMID for controller VMs (increments by 1 per VM)"
  type        = number
  default     = 801
}

variable "worker_vmid_base" {
  description = "Starting VMID for worker VMs (increments by 1 per VM)"
  type        = number
  default     = 851
}

#
# Networking
#

variable "network_prefix" {
  description = "First three octets of the network (e.g. '192.168.0')"
  type        = string
}

variable "network_cidr" {
  description = "Subnet prefix length"
  type        = number
  default     = 24
}

variable "gateway" {
  description = "Default gateway IP"
  type        = string
}

variable "nameserver" {
  description = "DNS nameserver assigned to all VMs"
  type        = string
  default     = "1.1.1.1"
}

variable "controller_ip_start" {
  description = "Last octet of the first controller IP (e.g. 221 → 192.168.0.221)"
  type        = number
}

variable "worker_ip_start" {
  description = "Last octet of the first worker IP (e.g. 231 → 192.168.0.231)"
  type        = number
}

variable "network_bridge" {
  description = "Proxmox Linux bridge to attach VM NICs to"
  type        = string
}

#
# VM template & storage
#

variable "template_name" {
  description = "Name of the Proxmox cloud-init template to clone"
  type        = string
}

variable "storage_pool" {
  description = "Proxmox storage pool used for disks, EFI, TPM and cloud-init drives"
  type        = string
}

#
# Controllers
#

variable "controller_cores" {
  description = "vCPU core count for controller VMs"
  type        = number
  default     = 4
}

variable "controller_memory_gb" {
  description = "RAM in GB for controller VMs"
  type        = number
  default     = 8
}

variable "controller_disk_size" {
  description = "Primary disk size for controller VMs"
  type        = string
  default     = "30G"
}

#
# Workers
#

variable "worker_cores" {
  description = "vCPU core count for worker VMs"
  type        = number
  default     = 8
}

variable "worker_memory_gb" {
  description = "RAM in GB for worker VMs"
  type        = number
  default     = 16
}

variable "worker_disk_size" {
  description = "Primary disk size for worker VMs"
  type        = string
  default     = "100G"
}

#
# Access
#

variable "ssh_public_key" {
  description = "SSH public key injected into all VMs via cloud-init"
  type        = string
}
