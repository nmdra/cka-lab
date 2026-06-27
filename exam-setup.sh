#!/usr/bin/env bash
# =============================================================
# exam-setup.sh — CKA exam environment bootstrap
#
# SOURCE this file, don't execute it:
#   source ~/exam-setup.sh
#
# It is auto-sourced from ~/.bashrc on all lab nodes.
# Mirrors the setup you'd do in the first 2 minutes of the real exam.
# =============================================================

# ── kubectl alias + completion ────────────────────────────────
alias k=kubectl
# shellcheck source=/dev/null
source <(kubectl completion bash)
complete -F __start_kubectl k     # make completion work on alias too

# ── Dry-run / force-delete shortcuts ─────────────────────────
export do="--dry-run=client -o yaml"   # k run nginx --image=nginx $do
export now="--force --grace-period=0"  # k delete pod nginx $now

# ── Editor ────────────────────────────────────────────────────
export EDITOR=vim
export KUBE_EDITOR=vim

# ── kubeconfig ────────────────────────────────────────────────
export KUBECONFIG=/home/vagrant/.kube/config

# ── Handy PS1 showing current context/namespace ───────────────
# Shows: [context|namespace] user@host:~$
_kube_ps1() {
  local ctx ns
  ctx=$(kubectl config current-context 2>/dev/null) || return
  ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
  ns="${ns:-default}"
  echo "[${ctx}|${ns}]"
}
PS1='\[\e[36m\]$(_kube_ps1)\[\e[0m\] \u@\h:\w\$ '

# ── Useful aliases ────────────────────────────────────────────
alias kgp='kubectl get pods -o wide'
alias kgn='kubectl get nodes -o wide'
alias kgs='kubectl get svc -o wide'
alias kge='kubectl get events --sort-by=.lastTimestamp'
alias kdp='kubectl describe pod'
alias kdn='kubectl describe node'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kns='kubectl config set-context --current --namespace'   # kns mynamespace
alias kctx='kubectl config use-context'

# ── vim settings for YAML editing ────────────────────────────
# Written to ~/.vimrc if not already there
if [ ! -f ~/.vimrc ]; then
  cat > ~/.vimrc <<'VIMRC'
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
set number
set ruler
syntax on
VIMRC
fi
