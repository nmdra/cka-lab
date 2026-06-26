# configs/ — auto-populated during provisioning
#
# Files written here after `vagrant up`:
#   config    — kubeconfig (use with: export KUBECONFIG=configs/config)
#   join.sh   — kubeadm join command (used by worker provisioning)
#
# Use from host:
#   export KUBECONFIG=$PWD/configs/config
#   kubectl get nodes
