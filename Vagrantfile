# -*- mode: ruby -*-
# vi: set ft=ruby tabstop=2 expandtab shiftwidth=2 softtabstop=2 :

def enable_3d(cfg)
  cfg.vm.provider "virtualbox" do |v|
    v.customize ['modifyvm', :id, '--vram', 256]
    v.customize ['modifyvm', :id, '--accelerate3d', 'on']
  end
end

def enable_root_ssh(cfg)
  pkey_file = "#{ENV['HOME']}/.ssh/id_rsa.pub"
  pkey = File.read(pkey_file)
  cfg.vm.provision 'shell',
    inline:
      "mkdir -m 700 -p ~/.ssh && " +
      "install -m 600 /dev/null ~/.ssh/authorized_keys && " +
      "echo '#{pkey}' >> ~/.ssh/authorized_keys"
end
def enable_vagrant_ssh(cfg)
  pkey_file = "#{ENV['HOME']}/.ssh/id_rsa.pub"
  pkey = File.read(pkey_file)
  cfg.vm.provision 'shell',
    privileged: false,
    inline:
      "echo '#{pkey}' >> ~/.ssh/authorized_keys"
end

def ram1g(cfg)
  cfg.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 1024
  end
end

def ram2g(cfg)
  cfg.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 2048
  end
end

def ram4g(cfg)
  cfg.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 4096
  end
end

def linux(cfg)
  cfg.vm.synced_folder ".", "/vagrant", :disabled => true
  cfg.cache.scope = :machine if Vagrant.has_plugin? "vagrant-cachier"
  enable_root_ssh(cfg)
end

def bsd(cfg)
  cfg.vm.synced_folder ".", "/vagrant", :disabled => true
  cfg.ssh.shell = "sh"
  cfg.vm.provider "virtualbox" do |v|
    v.customize ['modifyvm', :id, '--hwvirtex', "on"]
  end
  enable_vagrant_ssh(cfg)
  enable_root_ssh(cfg)
end

def windows(cfg)
  # The default vagrant share is necessary while ansible's windows support for
  # copy and template is lacking.
  # cfg.vm.synced_folder ".", "/vagrant", :disabled => true
  cfg.cache.scope = :machine if Vagrant.has_plugin? "vagrant-cachier"
end

def osx(cfg)
  cfg.ssh.insert_key = false
  cfg.vm.synced_folder ".", "/vagrant", :disabled => true
  enable_vagrant_ssh(cfg)
  enable_root_ssh(cfg)
end

Vagrant.configure("2") do |config|

  servers = {
    # master
    :master => {
      :ip => '172.30.70.40',
      :provisioner => [:linux, :ram1g],
      :box => 'ubuntu1504',
      :primary => true,
    },
    # ubuntu build slave
    :ububuild => {
      :ip => '172.30.70.41',
      :provisioner => [:linux, :ram2g],
      :box => 'ubuntu1504',
    },
    # debian build slave
    :debbuild => {
      :ip => '172.30.70.42',
      :provisioner => [:linux, :ram2g],
      :box => 'debian81',
    },
    # windows build slave
    :winbuild => {
      :ip => '172.30.70.43',
      :provisioner => [:windows, :ram2g, :enable_3d],
      :box => 'eval-win81x64-enterprise',
    },
    # osx build slave
    :osxbuild  => {
      :ip => '172.30.70.44',
      :provisioner => [:osx, :ram2g, :enable_3d],
      :box => 'osx1010',
    },
    # fifoci build slave
    :dffbuild => {
      :ip => '172.30.70.45',
      :provisioner => [:linux, :ram2g, :enable_3d],
      :box => 'ubuntu1504',
    },
    # www
    :www => {
      :ip => '172.30.70.46',
      :provisioner => [:linux, :ram1g],
      :box => 'ubuntu1504',
    },
    # freebsd build slave
    :bsdbuild => {
      :ip => '172.30.70.47',
      :provisioner => [:bsd, :ram2g],
      :box => 'freebsd102',
    },
  }

  servers.each do |server_name, server_details|
    config.vm.define(server_name,
                     primary: server_details[:primary] || false,
                     autostart: server_details.has_key?(:autostart) ?
                         server_details[:autostart] : true
                    ) do |cfg|
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

