# -*- mode: ruby -*-
# vi: set ft=ruby :

# CKA Lab — 1 control-plane + 2 workers

NUM_WORKERS = 2
IP_PREFIX   = "192.168.56."
IP_START    = 10

Vagrant.configure("2") do |config|
  config.vm.box              = "bento/ubuntu-24.04"
  config.vm.box_check_update = false

  # Suppress the vagrant-vbguest plugin if installed (deprecated + broken on Ubuntu 24.04)
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.no_install = true
  end

  # ── /etc/hosts on every VM ──────────────────────────────────
  config.vm.provision "shell", inline: <<-SHELL
    set -e
    # Idempotent: only add if not already present
    grep -qF "#{IP_PREFIX}#{IP_START} controlplane" /etc/hosts || \
      echo "#{IP_PREFIX}#{IP_START} controlplane" >> /etc/hosts
    #{(1..NUM_WORKERS).map { |i|
      "grep -qF \"#{IP_PREFIX}#{IP_START + i} worker0#{i}\" /etc/hosts || " \
      "echo \"#{IP_PREFIX}#{IP_START + i} worker0#{i}\" >> /etc/hosts"
    }.join("\n    ")}
  SHELL

  # ── Control-plane ────────────────────────────────────────────
  config.vm.define "controlplane" do |cp|
    cp.vm.hostname = "controlplane"
    cp.vm.network "private_network", ip: "#{IP_PREFIX}#{IP_START}"

    cp.vm.provider "virtualbox" do |vb|
      vb.name   = "cka-controlplane"
      vb.memory = 2048
      vb.cpus   = 2
      # Disable audio/USB to reduce footprint
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--usb", "off"]
    end
  end

  # ── Workers ───────────────────────────────────────────────────
  (1..NUM_WORKERS).each do |i|
    config.vm.define "worker0#{i}" do |w|
      w.vm.hostname = "worker0#{i}"
      w.vm.network "private_network", ip: "#{IP_PREFIX}#{IP_START + i}"

      w.vm.provider "virtualbox" do |vb|
        vb.name   = "cka-worker0#{i}"
        vb.memory = 1024
        vb.cpus   = 1
        vb.customize ["modifyvm", :id, "--audio", "none"]
        vb.customize ["modifyvm", :id, "--usb", "off"]
      end

      # Run Ansible once — after the LAST worker is up — targeting all hosts
      if i == NUM_WORKERS
        w.vm.provision "ansible" do |ansible|
          ansible.limit    = "all"
          ansible.playbook = "playbooks/site.yml"
          ansible.groups   = {
            "control" => ["controlplane"],
            "workers" => (1..NUM_WORKERS).map { |j| "worker0#{j}" }
          }
          ansible.extra_vars = {
            # ── Pin to 1.35.x for exact CKA exam alignment (1.36.2 = latest stable) ──
            k8s_version: "1.36.2",
            k8s_minor:   "1.36",
          }
          ansible.verbose = false
        end
      end
    end
  end
end
