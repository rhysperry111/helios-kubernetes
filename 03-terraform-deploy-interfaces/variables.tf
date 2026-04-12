#
# CNI
#

variable "k8s_vip" {
  description = "kube-vip virtual IP address"
  type        = string
}

#
# CSI
#

variable "ceph_cluster_id" {
  description = "CEPH cluster ID for CSI to join"
  type        = string
}

variable "ceph_monitors" {
  description = "CEPH monitors for CSI to talk to (comma seperated)"
  type        = string
}

variable "ceph_user" {
  description = "CEPH user for CSI to authenticate as"
  type        = string
}

variable "ceph_key" {
  description = "CEPH key for CSI to authenticate with"
  type        = string
  sensitive   = true
}

variable "ceph_rbd_pool" {
  description = "CEPH OSD pool to allocate RBD from"
  type        = string
}

variable "ceph_cephfs_name" {
  description = "CEPH CephFS to allocate RWX volumes from"
  type        = string
}

variable "ceph_cephfs_subvolumegroup" {
  description = "CEPH CephFS subvolumegroup to allocate RWX volumes from"
  type        = string
}

#
# Chart versions
#

variable "cilium_chart_version" {
  description = "Cilium Helm chart version"
  type        = string
}

variable "ceph_csi_rbd_chart_version" {
  description = "ceph-csi-rbd Helm chart version"
  type        = string
}

variable "ceph_csi_cephfs_chart_version" {
  description = "ceph-csi-cephfs Helm chart version"
  type        = string
}
