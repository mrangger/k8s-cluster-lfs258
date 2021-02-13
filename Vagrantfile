# -*- mode: ruby -*-
# vi: set ft=ruby :

WorkerNodes = 1
domainName = "k8s.local"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
  
#  config.vm.network "public_network", use_dhcp_assigned_default_route: true
  config.vm.network "public_network", 
    use_dhcp_assigned_default_route: true
  config.vm.provision "shell", path: "provision.sh"
  
  config.vm.define "master" do |master|
#    master.vm.network "private_network", ip: "172.42.42.99", netmask: "255.255.255.0",
#      auto_config: true,
#      virtualbox__intnet: "k8s-net"
    master.vm.hostname = "master.#{domainName}"  
    master.vm.provision "shell", path: "provision_master.sh"
    config.vm.provider "virtualbox" do |vb|
      vb.name = "K8s Master"
      vb.memory = 3072
      vb.cpus = 2
    end
  end

  (1..WorkerNodes).each do |i|
    config.vm.define "worker#{i}" do |worker|
#      worker.vm.network "private_network", ip: "172.42.42.#{i+10}", netmask: "255.255.255.0",
#        auto_config: true,
#        virtualbox__intnet: "k8s-net"
      worker.vm.hostname = "worker#{i}.#{domainName}"
      worker.vm.provider "virtualbox" do |vb|
        vb.name = "K8s Worker #{i}"
        vb.memory = 1024
        vb.cpus = 1
      end
	    worker.vm.provision "shell", path: "provision_worker.sh"
	  end
	end
  
end
