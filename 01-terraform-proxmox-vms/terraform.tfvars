# Proxmox Cluster
proxmox_nodes = ["prox", "brox", "crox", "drox"]

# Networking
network_prefix      = "192.168.0"
gateway             = "192.168.0.1"
control_plane_vip   = "192.168.0.220" 
controller_ip_start = 221
worker_ip_start     = 231
network_bridge      = "vmbr0"

# VM template and storage
template_name = "arch-cloud-template"
storage_pool  = "vault"

# Access
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBORUBq28eI+KWbYpHZhA3PiZrzBTNenyP+/yKRSScnL rhys@pegasus"
