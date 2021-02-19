# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
WorkerNodeCount = 2


masterNode = {
  :cpus     => 2,
  :hostname => "master",
  :image    => "ubuntu/focal64",
  :memory   => 3072,
  :vmName   => "K8s Master"
}

workerNode = {
  :cpus     => 1,
  :hostname => "worker",
  :image    => "ubuntu/focal64",
  :memory   => 1024,
  :vmName   => "K8s Worker"
}

network = {
  :domainName => "k8s.local",
  :podSubnet  => "192.168.88.0/24",
  :vmSubnet   => "192.168.202."
}


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = masterNode[:image]
  config.vm.provision "shell", path: "provision.sh"
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.synced_folder_opts = {
       owner: "_apt",
       group: "_apt"
    }
  end
  
  config.vm.define "master" do |master|
    master.vm.network "private_network", ip: network[:vmSubnet] + "5"
    master.vm.hostname = masterNode[:hostname] + '.' + network[:domainName]
    master.vm.provider "virtualbox" do |vb|
      vb.cpus = masterNode[:cpus]
      vb.memory = masterNode[:memory]

      vb.linked_clone = true
      vb.name = masterNode[:vmName]
    end

    master.vm.provision "shell", path: "provision_master.sh", args: network[:podSubnet]
  end

  (1..WorkerNodeCount).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.box = workerNode[:image]
      worker.vm.network "private_network", ip: network[:vmSubnet] + "#{i+10}"
      worker.vm.hostname = workerNode[:hostname] + "-#{i}." + network[:domainName]
 

      worker.vm.provider "virtualbox" do |vb|
        vb.cpus = workerNode[:cpus]
        vb.memory = workerNode[:memory]
        vb.linked_clone = true
        vb.name = workerNode[:vmName] + " #{i}"
      end
      
	    worker.vm.provision "shell", path: "provision_worker.sh"
	  end
	end
end

