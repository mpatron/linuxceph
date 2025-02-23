# -*- mode: ruby -*-

VM_COUNT = 6
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
          "vm_count": VM_COUNT,
          "DOMAIN": DOMAIN
        }
      end
    end
  end
end
