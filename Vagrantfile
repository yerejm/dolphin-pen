# -*- mode: ruby -*-
# vi: set ft=ruby tabstop=2 expandtab shiftwidth=2 softtabstop=2 :

def provision_3d(cfg)
  cfg.vm.provider "virtualbox" do |v|
    v.customize ['modifyvm', :id, '--vram', 256]
    v.customize ['modifyvm', :id, '--accelerate3d', 'on']
  end
end
def provision_unix(cfg)
  cfg.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 2048
  end
  cfg.vm.synced_folder ".", "/vagrant", :disabled => true
  cfg.cache.scope = :box if Vagrant.has_plugin? "vagrant-cachier"
end

def provision_windows(cfg)
  cfg.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 4096
  end
  cfg.vm.synced_folder ".", "/vagrant", :disabled => true
  cfg.cache.scope = :box if Vagrant.has_plugin? "vagrant-cachier"
end

def provision_osx(cfg)
  cfg.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 4096
  end
  cfg.ssh.insert_key = false
  cfg.vm.synced_folder ".", "/vagrant", :disabled => true
end

Vagrant.configure("2") do |config|

  servers = {
    # master
    :master => {
      :ip => '172.118.70.40',
      :provisioner => [:provision_unix, :provision_3d],
      :box => 'ubuntu1410',
      :primary => true,
      :ports => { 8010 => 8010, 8443 => 443, 8888 => 80 },
    },
    # ubuntu build slave
    :ububuild => {
      :ip => '172.118.70.41',
      :provisioner => [:provision_unix],
      :box => 'ubuntu1410',
    },
    # debian build slave
    :debbuild => {
      :ip => '172.118.70.42',
      :provisioner => [:provision_unix],
      :box => 'debian78',
    },
    # windows build slave
    :winbuild => {
      :ip => '172.118.70.43',
      :provisioner => [:provision_windows, :provision_3d],
      :box => 'eval-win81x64-enterprise'
    },
    # osx build slave
    :osxbuild  => {
      :ip => '172.118.70.44',
      :provisioner => [:provision_osx, :provision_3d],
      :box => 'osx1010-desktop'
    },
  }

  servers.each do |server_name, server_details|
    config.vm.define(server_name, primary: server_details.has_key?(:primary)) do |cfg|
      cfg.vm.box = server_details[:box]
      cfg.vm.host_name = server_name.to_s
      cfg.vm.network(:private_network, ip: server_details[:ip])
      (server_details[:ports] || {}).each do |host_port, guest_port|
        cfg.vm.network "forwarded_port", guest: guest_port, host: host_port
      end
      server_details[:provisioner].each { |p| method(p).call(cfg) }
    end
  end
end

