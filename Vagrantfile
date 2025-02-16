# -*- mode: ruby -*-

VM_COUNT = 2
VM_RAM = "4096" # 1024 2048 3072 4096 6144 8192
VM_CPU = 2
IMAGE = "almalinux/9"
DOMAIN = "jobjects.net"

Vagrant.configure("2") do |config|
  config.vm.box = IMAGE
  config.vm.box_check_update = false
  config.vm.boot_timeout = 600 # default=300s
  config.vm.synced_folder ".", "/vagrant"
  # !! ne fonctionne que sur linux avec libvirt !!
  # Désolez pour les windowsiens....
  config.vm.provider :libvirt do |lbv|
    lbv.cpus = VM_CPU
    lbv.nested = true
    lbv.memory = VM_RAM
    lbv.storage :file, :type => 'qcow2', name: "extradisk1", size: "1GB"
    lbv.storage :file, :type => 'qcow2', name: "extradisk2", size: "1GB"
    lbv.storage :file, :type => 'qcow2', name: "extradisk3", size: "1GB"
    lbv.storage :file, :type => 'qcow2', name: "extradisk4", size: "1GB"
  end
  (0..(VM_COUNT-1)).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.hostname = "node#{i}.#{DOMAIN}"
      node.vm.network "private_network", ip: "192.168.56.14#{i}"
      node.vm.provision "ansible" do |a|
        a.verbose = "v"
        a.playbook = "provision-playbook.yml"
        a.extra_vars = {
          vm_count: VM_COUNT,
          DOMAIN: DOMAIN
        }
      end


#       node.vm.provision "shell", run: "always", inline: <<-SHELL1
#   for N in {0..#{VM_COUNT-1}}; do
#   [[ ! $(grep "192.168.56.14${N} node${N}.jobjects.net node${N}" /etc/hosts) ]] && echo $(echo "192.168.56.14${N} node${N}.jobjects.net node${N}" | sudo tee -a /etc/hosts)
# done
# sudo sed -i '/127.0.1.1/d' /etc/hosts
# sudo hostnamectl set-hostname node#{i}.jobjects.net
# sudo sed -i -e "\\#PasswordAuthentication no# s#PasswordAuthentication no#PasswordAuthentication yes#g" /etc/ssh/sshd_config
# sudo systemctl restart sshd
# # sudo apt-get update -y && sudo apt-get install sshpass -y
# sudo dnf update -y && dnf install sshpass bash-completion -y 
# # =============================================================================
# # Ajout certificat ssh pour vagrant
# bash -c 'cat << EOF > /home/vagrant/.ssh/id_ed25519
# -----BEGIN OPENSSH PRIVATE KEY-----
# b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
# QyNTUxOQAAACDi8uu07CqVhPz1mO7Brddi/zofsEpn6bsf0Jh3S9ffMAAAAJCou9OoqLvT
# qAAAAAtzc2gtZWQyNTUxOQAAACDi8uu07CqVhPz1mO7Brddi/zofsEpn6bsf0Jh3S9ffMA
# AAAEBytj//ZeYFeYIBVUUhsT76YZdSm/2vC3uW/v6n2rp65+Ly67TsKpWE/PWY7sGt12L/
# Oh+wSmfpux/QmHdL198wAAAADXZhZ3JhbnRAbm9kZTA=
# -----END OPENSSH PRIVATE KEY-----
# EOF'
# bash -c 'cat << EOF > /home/vagrant/.ssh/id_ed25519.pub
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLy67TsKpWE/PWY7sGt12L/Oh+wSmfpux/QmHdL198w vagrant@node0
# EOF'
# grep -q --no-messages "AAaAAC3NzaC1lZDI1NTE5AAAAIOLy67TsKpWE" /home/vagrant/.ssh/authorized_keys && echo "Deja present dans /home/vagrant/.ssh/authorized_keys" || bash -c 'echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLy67TsKpWE/PWY7sGt12L/Oh+wSmfpux/QmHdL198w vagrant@node0" >> /home/vagrant/.ssh/authorized_keys'
# sudo chmod 600 /home/vagrant/.ssh/id_ed25519
# sudo chmod 600 /home/vagrant/.ssh/id_ed25519.pub
# sudo chmod 600 /home/vagrant/.ssh/authorized_keys
# for N in {0..#{VM_COUNT}}; do
#   if [[ ! -f /home/vagrant/.ssh/config ]]; then
#     sudo touch /home/vagrant/.ssh/config
#     sudo chmod 600 /home/vagrant/.ssh/config
#     sudo chown vagrant:vagrant /home/vagrant/.ssh/config
#   fi
#   if [[ ! $(grep "Host node${N}" /home/vagrant/.ssh/config) ]]; then
#     echo "Host node${N}" | sudo tee -a /home/vagrant/.ssh/config
#     echo "    Hostname 192.168.56.14${N}" | sudo tee -a /home/vagrant/.ssh/config
#     echo "    StrictHostKeyChecking no" | sudo tee -a /home/vagrant/.ssh/config
#   fi
# done
# sudo chmod 600 /home/vagrant/.ssh/config
# sudo chown vagrant:vagrant -R /home/vagrant/.ssh
# bash -c 'cat << EOF > /home/vagrant/maj.sh
# #!/bin/bash
# echo "=== Maj OS ==="
# sudo apt autoclean -yqq && sudo apt update -yqq && sudo apt upgrade -yqq && sudo apt autoremove --purge -yqq
# echo "=== OS need to restart ? ==="
# if [ -f /var/run/reboot-required ]; then
#   echo "Reboot required"
# else
#   echo "No reboot need"
# fi
# EOF'
# sudo chmod +x /home/vagrant/maj.sh
# # /home/vagrant/maj.sh
# SHELL1
    end
  end
end
