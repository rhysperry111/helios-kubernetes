terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_token_id
  pm_api_token_secret = var.proxmox_token_secret
}

locals {
  vm_defaults = {
    clone              = var.template_name
    full_clone         = true
    os_type            = "cloud-init"
    start_at_node_boot = true
    vm_state           = "running"
    hotplug            = "network,disk,usb"
    bios               = "ovmf"
    scsihw             = "virtio-scsi-single"
    boot               = "order=virtio0"
    agent              = 1
    hastate            = "started"
  }
}

#
# Resource pool
#

resource "proxmox_pool" "kubernetes" {
  poolid  = "kubernetes"
  comment = "Managed Kubernetes Cluster"
}

#
# Controllers
#

resource "proxmox_vm_qemu" "controllers" {
  depends_on = [proxmox_pool.kubernetes]

  count = var.controller_count
  name  = format("controller-%02d", count.index + 1)
  vmid  = var.controller_vmid_base + count.index
  pool  = proxmox_pool.kubernetes.poolid
  tags  = "terraform,kubernetes,controller"

  target_node = element(var.proxmox_nodes, count.index % length(var.proxmox_nodes))

  clone              = local.vm_defaults.clone
  full_clone         = local.vm_defaults.full_clone
  os_type            = local.vm_defaults.os_type
  start_at_node_boot = local.vm_defaults.start_at_node_boot
  vm_state           = local.vm_defaults.vm_state
  hotplug            = local.vm_defaults.hotplug
  bios               = local.vm_defaults.bios
  scsihw             = local.vm_defaults.scsihw
  boot               = local.vm_defaults.boot
  agent              = local.vm_defaults.agent
  hastate            = local.vm_defaults.hastate

  cpu {
    type  = "host"
    cores = var.controller_cores
  }

  memory = var.controller_memory_gb * 1024

  vga {
    type = "qxl"
  }

  efidisk {
    efitype = "4m"
    storage = var.storage_pool
  }

  tpm_state {
    storage = var.storage_pool
    version = "v2.0"
  }

  disks {
    virtio {
      virtio0 {
        disk {
          size    = var.controller_disk_size
          storage = var.storage_pool
        }
      }
    }

    ide {
      ide0 {
        cloudinit {
          storage = var.storage_pool
        }
      }
    }
  }

  network {
    id       = 0
    model    = "virtio"
    bridge   = var.network_bridge
    firewall = true
  }

  ipconfig0  = "ip=${var.network_prefix}.${var.controller_ip_start + count.index}/${var.network_cidr},gw=${var.gateway}"
  nameserver = var.nameserver

  sshkeys = var.ssh_public_key
}

#
# Workers
#

resource "proxmox_vm_qemu" "workers" {
  depends_on = [proxmox_pool.kubernetes]

  count = var.worker_count
  name  = format("worker-%02d", count.index + 1)
  vmid  = var.worker_vmid_base + count.index
  pool  = proxmox_pool.kubernetes.poolid
  tags  = "terraform,kubernetes,worker"

  target_node = element(reverse(var.proxmox_nodes), count.index % length(var.proxmox_nodes))

  clone              = local.vm_defaults.clone
  full_clone         = local.vm_defaults.full_clone
  os_type            = local.vm_defaults.os_type
  start_at_node_boot = local.vm_defaults.start_at_node_boot
  vm_state           = local.vm_defaults.vm_state
  hotplug            = local.vm_defaults.hotplug
  bios               = local.vm_defaults.bios
  scsihw             = local.vm_defaults.scsihw
  boot               = local.vm_defaults.boot
  agent              = local.vm_defaults.agent
  hastate            = local.vm_defaults.hastate

  cpu {
    type  = "host"
    cores = var.worker_cores
  }

  memory = var.worker_memory_gb * 1024

  vga {
    type = "qxl"
  }

  efidisk {
    efitype = "4m"
    storage = var.storage_pool
  }

  tpm_state {
    storage = var.storage_pool
    version = "v2.0"
  }

  disks {
    virtio {
      virtio0 {
        disk {
          size    = var.worker_disk_size
          storage = var.storage_pool
        }
      }
    }

    ide {
      ide0 {
        cloudinit {
          storage = var.storage_pool
        }
      }
    }
  }

  network {
    id       = 0
    model    = "virtio"
    bridge   = var.network_bridge
    firewall = true
  }

  ipconfig0  = "ip=${var.network_prefix}.${var.worker_ip_start + count.index}/${var.network_cidr},gw=${var.gateway}"
  nameserver = var.nameserver

  sshkeys = var.ssh_public_key
}

#
# Ansible inventory
#

resource "local_file" "ansible_inventory" {
  filename = "../02-ansible-install-kubernetes/inventory.autogen.yaml"
  content = templatefile("./inventory.tpl", {
    controllers         = proxmox_vm_qemu.controllers
    workers             = proxmox_vm_qemu.workers
    network_prefix      = var.network_prefix
    controller_ip_start = var.controller_ip_start
    worker_ip_start     = var.worker_ip_start
  })
}
