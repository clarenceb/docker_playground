# -*- mode: ruby -*-
# vi: set ft=ruby :

`mkdir -p cache/m2`

def create_synced_dir(config, host_dir, vm_dir, owner = 'vagrant', group = 'vagrant')
  config.vm.synced_folder host_dir, vm_dir, owner: owner, group: group if File.directory?(host_dir)
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end

  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "promserver"

  # Cache Maven dependencies on host to save time when rebuilding VM.
  create_synced_dir(config, "cache/m2/", "/home/vagrant/.m2")

  # Consul interface
  config.vm.network "forwarded_port", guest: 8500, host: 8500
  # Prometheus Server
  config.vm.network "forwarded_port", guest: 9090, host: 9090
  # Prometheus Alert Manager
  config.vm.network "forwarded_port", guest: 9093, host: 9093
  # Prometheus Dashboard
  config.vm.network "forwarded_port", guest: 3000, host: 3000

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provider "virtualbox" do |vb|
     vb.customize ["modifyvm", :id, "--memory", "4096"]
     vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

  # Update apt cache to latest
  config.vm.provision "shell",  inline: "apt-get update -y"

  config.vm.provision "shell",  path: "provisioning/install-dependencies.sh"

  # Install and configure docker
  config.vm.provision "docker"

  # Load Docker images from local cache if available over fetching from Docker hub
  config.vm.provision "shell",  path: "provisioning/docker-cache-images.sh"

  config.vm.provision "shell",  path: "provisioning/install-docker-compose.sh"
end
