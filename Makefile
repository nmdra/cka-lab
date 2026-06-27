.DEFAULT_GOAL := help
.PHONY: help up halt down destroy clean rebuild provision status nodes top ssh-cp ssh-w1 ssh-w2

KUBECONFIG_PATH ?= configs/config

help: ## Show this help menu
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

up: ## Build and bootstrap cluster from scratch (~4-5 min)
	vagrant up

halt: ## Stop all cluster VMs safely
	vagrant halt
down: halt ## Alias for halt

provision: ## Re-run Ansible configuration without recreating VMs (fast iteration)
	vagrant provision

destroy: ## Tear down and delete all cluster VMs
	vagrant destroy -f
clean: destroy ## Alias for destroy

rebuild: destroy up ## Nuclear option: wipe VMs and recreate from scratch

status: ## Check Vagrant VM state and Kubernetes cluster node health
	@echo "── Vagrant Status ──────────────────────────────────────────"
	@vagrant status
	@echo ""
	@echo "── Cluster Nodes ───────────────────────────────────────────"
	@if [ -f $(KUBECONFIG_PATH) ]; then \
		kubectl --kubeconfig=$(KUBECONFIG_PATH) get nodes -o wide; \
	else \
		echo "Kubeconfig not found at $(KUBECONFIG_PATH). Is the cluster booted?"; \
	fi

nodes: ## Quick shortcut: get cluster nodes
	@kubectl --kubeconfig=$(KUBECONFIG_PATH) get nodes -o wide

top: ## Quick shortcut: check node CPU and memory usage
	@kubectl --kubeconfig=$(KUBECONFIG_PATH) top nodes

ssh-cp: ## SSH into controlplane VM
	vagrant ssh controlplane

ssh-w1: ## SSH into worker01 VM
	vagrant ssh worker01

ssh-w2: ## SSH into worker02 VM
	vagrant ssh worker02
