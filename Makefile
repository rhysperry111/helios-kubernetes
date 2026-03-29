CONFIG    := helios.yaml
GENSCRIPT := generate-config.py

STEP1_DIR := 01-terraform-proxmox-vms
STEP2_DIR := 02-ansible-install-kubernetes
STEP3_DIR := 03-terraform-deploy-interfaces
STEP4_DIR := 04-terraform-setup-networking
STEP5_DIR := 05-terraform-deploy-gitops


.PHONY: all generate step1 step2 step3 step4 step5 \
        destroy-step1 destroy-step3 destroy-step4 destroy-step5 \
        destroy-all clean help


help:
	@echo ""
	@echo "HELIOS Kubernetes"
	@echo "================="
	@echo ""
	@echo "  make generate       Regenerate per-step vars from helios.yaml"
	@echo "  make step1          Provision Proxmox VMs"
	@echo "  make step2          Install Kubernetes (Ansible)"
	@echo "  make step3          Deploy cluster interfaces (Cilium, Longhorn)"
	@echo "  make step4          Setup networking (BGP, DNS, TLS)"
	@echo "  make step5          Deploy GitOps (ArgoCD, GitLab)"
	@echo "  make all            Run full pipeline (1 -> 5)"
	@echo ""
	@echo "  make destroy-step5  Tear down GitOps"
	@echo "  make destroy-step4  Tear down networking"
	@echo "  make destroy-step3  Tear down cluster interfaces"
	@echo "  make destroy-step1  Destroy Proxmox VMs"
	@echo "  make destroy-all    Tear down everything (5 -> 1)"
	@echo ""
	@echo "  make clean          Remove all generated / autogen files"
	@echo ""


generate:
	@python3 $(GENSCRIPT) --config $(CONFIG)


all: step1 step2 step3 step4 step5

step1: generate
	@echo "\n========== Step 1: Provision Proxmox VMs ==========\n"
	cd $(STEP1_DIR) && terraform init -upgrade && terraform apply

step2:
	@echo "\n========== Step 2: Install Kubernetes ==========\n"
	cd $(STEP2_DIR) && ansible-playbook kubernetecize.yaml

step3: generate
	@echo "\n========== Step 3: Deploy Cluster Interfaces ==========\n"
	cd $(STEP3_DIR) && terraform init -upgrade && terraform apply

step4: generate
	@echo "\n========== Step 4: Setup Networking ==========\n"
	cd $(STEP4_DIR) && terraform init -upgrade && terraform apply

step5: generate
	@echo "\n========== Step 5: Deploy GitOps ==========\n"
	cd $(STEP5_DIR) && terraform init -upgrade && terraform apply


destroy-all: destroy-step5 destroy-step4 destroy-step3 destroy-step1

destroy-step5:
	@echo "\n========== Destroying Step 5: GitOps ==========\n"
	cd $(STEP5_DIR) && terraform destroy

destroy-step4:
	@echo "\n========== Destroying Step 4: Networking ==========\n"
	cd $(STEP4_DIR) && terraform destroy

destroy-step3:
	@echo "\n========== Destroying Step 3: Cluster Interfaces ==========\n"
	cd $(STEP3_DIR) && terraform destroy

destroy-step1:
	@echo "\n========== Destroying Step 1: Proxmox VMs ==========\n"
	cd $(STEP1_DIR) && terraform destroy


clean:
	rm -f $(STEP1_DIR)/helios.auto.tfvars
	rm -f $(STEP2_DIR)/group_vars/helios.auto.yaml
	rm -f $(STEP3_DIR)/helios.auto.tfvars
	rm -f $(STEP4_DIR)/helios.auto.tfvars
	rm -f $(STEP5_DIR)/helios.auto.tfvars
	find . -name '*.autogen.*' -delete
	@echo "Clean."
