# -*- mode: ruby -*-
# vi: set ft=ruby :

def create_synced_dir(config, host_dir, vm_dir, owner = 'vagrant', group = 'vagrant')
  unless File.directory?(host_dir)
    require 'fileutils'
    FileUtils.mkdir_p(host_dir)
  end
  config.vm.synced_folder host_dir, vm_dir, owner: owner, group: group
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

  # Update apt cache to latest
  config.vm.provision "shell",  inline: "apt-get update -y"

  config.vm.provision "shell",  path: "provisioning/install-dependencies.sh"

  # Install and configure docker
  config.vm.provision "docker"

  # Cache Maven dependencies on host to save time when rebuilding VM.
  create_synced_dir(config, "provisioning/cache/m2/", "/home/vagrant/.m2")

  config.vm.provision "shell",  path: "provisioning/docker-cache-images.sh"

  config.vm.define "promserver", primary: true do |server|
    server.vm.hostname = "promserver"

    # Shop Application UI
    server.vm.network "forwarded_port", guest: 8080, host: 8080
    # Consul interface
    server.vm.network "forwarded_port", guest: 8500, host: 8500
    # Prometheus Server
    server.vm.network "forwarded_port", guest: 9090, host: 9090
    # Prometheus Alert Manager
    server.vm.network "forwarded_port", guest: 9093, host: 9093
    # Prometheus Dashboard
    server.vm.network "forwarded_port", guest: 3000, host: 3000

    server.vm.network "private_network", ip: "192.168.33.10"

    server.vm.provider "virtualbox" do |vb|
       vb.customize ["modifyvm", :id, "--memory", "4096"]
       vb.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end

  config.vm.define "server02" do |server|
    server.vm.hostname = "server02"

    server.vm.network "private_network", ip: "192.168.33.11"

    server.vm.provider "virtualbox" do |vb|
       vb.customize ["modifyvm", :id, "--memory", "1024"]
       vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end
end
