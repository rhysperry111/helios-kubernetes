# HELIOS Kubernetes on Proxmox IaC

> Scripts initially built for my homelab "HELIOS"

Basic scripts to get a barebones Kubernetes cluster deployed in Proxmox. Currently a fair amount of improvement needed to make things more modular and customizable, however it works well enough to deploy demo applications.

## Step 1 - Terraform create VMs

This step clones a base Arch cloud-init template to make controller and worker VMs. Uses the proxmox terraform provider which can sometimes be a little tempermental.

It generates an ansible inventory for the next step.

## Step 2 - Ansible install Kubernetes

This step installs kubernetes, associates tools and configurations on the controller and worker machines. It uses a basic kubeadm deployment for simplicity.

It generates a kubeconfig for the next step.

## Step 3 - Terraform deploy resources

This step installs all in-cluster resources such as Cilium CNI and Longhorn CSI.
