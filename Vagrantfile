# -*- mode: ruby -*-

VM_COUNT = 4
VM_RAM = "6144" # 1024 2048 3072 4096 6144 8192
VM_CPU = 6 # 2 3 4 5 6 7 8
IMAGE = "almalinux/9"
DOMAIN = "jobjects.net"
DOMAIN_IP_PATTERN = "192.168.56.14"
Vagrant.configure("2") do |config|
  config.vm.box = IMAGE
  config.vm.box_check_update = false
  config.vm.boot_timeout = 600 # default=300s
  # config.vm.synced_folder ".", "/vagrant"

  config.vm.provider :libvirt do |libvirt|
    libvirt.qemu_use_session = false
    libvirt.cpus = VM_CPU
    libvirt.nested = true
    libvirt.memory = VM_RAM
    # 6GB extra disk for OSD car à 5GB il ne veut pas l'installer
    libvirt.storage :file, :type => 'qcow2', name: "extradisk1", size: "10GB"
    libvirt.storage :file, :type => 'qcow2', name: "extradisk2", size: "10GB"
    # libvirt.storage :file, :type => 'qcow2', name: "extradisk3", size: "1GB"
    # libvirt.storage :file, :type => 'qcow2', name: "extradisk4", size: "1GB"
  end

  (1..VM_COUNT).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.hostname = "node#{i}.#{DOMAIN}"
      node.vm.network "private_network", ip: "#{DOMAIN_IP_PATTERN}#{i}"
      node.vm.provision "ansible" do |ansible|
        ansible.verbose = false # default=true ou "-vvv" pour debug
        # ansible.limit = "all"
        ansible.playbook = "provision-playbook.yml"
        ansible.extra_vars = {
          "vm_count": VM_COUNT,
          "vm_domain": DOMAIN,
          "vm_domain_ip_pattern": DOMAIN_IP_PATTERN
        }
      end
      # if i == VM_COUNT
      # end
    end
  end
end
