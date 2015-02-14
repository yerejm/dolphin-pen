# -*- mode: ruby -*-
# vi: set ft=ruby tabstop=2 expandtab shiftwidth=2 softtabstop=2 :

def provision_unix(vm)
  vm.synced_folder ".", "/vagrant", :disabled => true
end

def provision_windows(vm)
  vm.synced_folder ".", "/vagrant", :disabled => true
end

def provision_osx(vm)
  vm.synced_folder ".", "/vagrant", :disabled => true
end

Vagrant.configure("2") do |config|
  #
  # vagrant-cachier
  #
  # Install the plugin by running: vagrant plugin install vagrant-cachier
  # More information: https://github.com/fgrehm/vagrant-cachier
  #
  if Vagrant.has_plugin? "vagrant-cachier"
    config.cache.scope = :box
  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 4
  end

  servers = {
    # master
    :master => {
      :ip => '172.118.70.40',
      :provisioner => :provision_unix,
      :box => 'ubuntu1410',
      :primary => true,
    },
    # ubuntu build slave
    :ububuild => {
      :ip => '172.118.70.41',
      :provisioner => :provision_unix,
      :box => 'ubuntu1410',
    },
    # debian build slave
    :debbuild => {
      :ip => '172.118.70.42',
      :provisioner => :provision_unix,
      :box => 'debian77',
    },
    # windows build slave
    :winbuild => {
      :ip => '172.118.70.43',
      :provisioner => :provision_windows,
      :box => 'eval-win81x64-enterprise'
    },
    # osx build slave
    :osxbuild  => {
      :ip => '172.118.70.44',
      :provisioner => :provision_osx,
      :box => 'osx1010-desktop'
    },
  }

  servers.each do |server_name, server_details|
    config.vm.define(server_name, primary: server_details.has_key?(:primary)) do |cfg|
      cfg.vm.box = server_details[:box]
      cfg.vm.host_name = server_name.to_s
      cfg.vm.network(:private_network, ip: server_details[:ip])
      method(server_details[:provisioner]).call(cfg.vm)
    end
  end
end

